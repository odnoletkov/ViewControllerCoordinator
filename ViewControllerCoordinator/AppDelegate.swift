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

open class ViewControllerCoordinator {

    public private(set) var presentingViewController: UIViewController?

    open func start(from controller: UIViewController) {
        precondition(presentingViewController == nil)
        presentingViewController = controller
    }

    public func present(_ controller: UIViewController, animated: Bool) {
        presentingViewController!.present(controller, animated: animated)
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
        // Issue: Forget super call
        super.start(from: controller)

        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alertController.addAction(.init(title: "Continue", style: .default, handler: { _ in

            let pickerController = PHPickerViewController(configuration: .init(photoLibrary: .shared()))
            pickerController.delegate = self
            self.present(pickerController, animated: true)
        }))

        present(alertController, animated: true)

        // Issue: Wrong present: controller.present(alertController, animated: true)

        // Issue: Retain cycle: objc_setAssociatedObject(self, &key, alertController, .OBJC_ASSOCIATION_RETAIN)
    }
}

extension SampleCoordinator: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        print(#function)
    }
}
