import UIKit
import PhotosUI

@main
class AppDelegate: NSObject, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        let controller = UIViewController()
        controller.view.backgroundColor = .systemBackground

        window = UIWindow(frame: UIScreen.main.bounds)
        window!.rootViewController = UINavigationController(rootViewController: controller)
        window!.makeKeyAndVisible()

        controller.navigationItem.rightBarButtonItem = .init(systemItem: .action, primaryAction: .init { _ in
            let coordinator = SampleCoordinator(title: "Sample")
            coordinator.start(from: controller)
        })

        return true
    }
}

private var key = 0

open class ViewControllerCoordinator {

    public private(set) var presentingViewController: UIViewController?

    open func start(from controller: UIViewController) {
        precondition(presentingViewController == nil)
        presentingViewController = controller
    }

    public func present(_ controller: UIViewController, animated: Bool) {
        guard let presentingViewController else {
            preconditionFailure("presentingViewController not set")
        }
        objc_setAssociatedObject(controller, &key, self, .OBJC_ASSOCIATION_RETAIN)
        presentingViewController.present(controller, animated: animated)
    }

    deinit {
        print(#function)
    }
}

class SampleCoordinator: ViewControllerCoordinator {

    let title: String

    init(title: String) {
        self.title = title
    }

    override func start(from controller: UIViewController) {
        super.start(from: controller)

        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alertController.addAction(.init(title: "Continue", style: .default, handler: { _ in

            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = .max
            let pickerController = PHPickerViewController(configuration: configuration)
            pickerController.delegate = self

            // Issue: Present called on controller: controller.present(pickerController, animated: true)
            self.present(pickerController, animated: true)
        }))

        present(alertController, animated: true)

        // Issue: Retain cycle: objc_setAssociatedObject(self, &key, alertController, .OBJC_ASSOCIATION_RETAIN)
    }
}

extension SampleCoordinator: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        print(#function, results)
        picker.dismiss(animated: true)
    }
}
