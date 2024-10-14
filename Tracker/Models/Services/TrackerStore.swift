import CoreData
import UIKit

final class TrackerStore: NSObject, NSFetchedResultsControllerDelegate {

    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerEntity>?

    var onTrackersChanged: (() -> Void)?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }

    // Добавление нового трекера
    func addTracker(name: String, color: UIColor, emoji: String, schedule: [String], category: TrackerCategory) -> Tracker? {
        let trackerEntity = TrackerEntity(context: context)
        trackerEntity.id = UUID()
        trackerEntity.name = name
        trackerEntity.color = color
        trackerEntity.emoji = emoji
        trackerEntity.schedule = schedule as NSObject

        // Используем fetchCategoryEntity для привязки категории
        guard let categoryEntity = fetchCategoryEntity(for: category) else {
            print("Ошибка: Категория \(category.title) не найдена.")
            return nil
        }
        
        trackerEntity.category = categoryEntity
        categoryEntity.addToTrackers(trackerEntity)

        do {
            try context.save()
            return Tracker(id: trackerEntity.id!, name: name, color: color, emoji: emoji, schedule: schedule, isPinned: false)
        } catch {
            print("Ошибка при сохранении трекера: \(error)")
            return nil
        }
    }
    
    func deleteTracker(with id: UUID, completion: @escaping (Bool) -> Void) {
        let fetchRequest: NSFetchRequest<TrackerEntity> = TrackerEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let trackerEntity = results.first {
                context.delete(trackerEntity)
                try context.save()
                completion(true)
            } else {
                completion(false)
            }
        } catch {
            print("Ошибка при удалении трекера: \(error)")
            completion(false)
        }
    }
    
    func togglePinStatus(for trackerID: UUID, completion: @escaping (Bool) -> Void) {
        let fetchRequest: NSFetchRequest<TrackerEntity> = TrackerEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerID as CVarArg)

        do {
            if let trackerEntity = try context.fetch(fetchRequest).first {
                trackerEntity.isPinned.toggle()  // Инвертируем статус
                try context.save()
                completion(true)  // Успех
            } else {
                completion(false)  // Трекер не найден
            }
        } catch {
            print("Ошибка при изменении статуса закрепления: \(error)")
            completion(false)  // Ошибка
        }
    }
    
    // Метод делегата для уведомления об изменениях в данных
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onTrackersChanged?()
    }
    
    func fetchAllTrackers() -> [Tracker] {
        guard let trackerEntities = fetchedResultsController?.fetchedObjects else { return [] }
        return trackerEntities.compactMap { tracker(from: $0) }
    }

    func fetchCategoryForTracker(trackerID: UUID) -> TrackerCategoryEntity? {
        let fetchRequest: NSFetchRequest<TrackerEntity> = TrackerEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerID as CVarArg)
        
        do {
            if let trackerEntity = try context.fetch(fetchRequest).first {
                return trackerEntity.category
            }
        } catch {
            print("Ошибка при загрузке категории трекера: \(error)")
        }
        return nil
    }

    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerEntity> = TrackerEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        fetchedResultsController?.delegate = self

        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Ошибка при загрузке трекеров: \(error)")
        }
    }
    
    // Поиск категории по модели TrackerCategory
    private func fetchCategoryEntity(for category: TrackerCategory) -> TrackerCategoryEntity? {
        let fetchRequest: NSFetchRequest<TrackerCategoryEntity> = TrackerCategoryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", category.title)
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Ошибка при загрузке категории: \(error)")
            return nil
        }
    }
}

extension TrackerStore {
    // Преобразование TrackerEntity в Tracker
    private func tracker(from entity: TrackerEntity) -> Tracker? {
        guard let id = entity.id,
              let name = entity.name,
              let color = entity.color as? UIColor,
              let emoji = entity.emoji,
              let isPinned = entity.isPinned as? Bool,
              let schedule = entity.schedule as? [String] else {
            return nil
        }
        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule, isPinned: isPinned)
    }
}
