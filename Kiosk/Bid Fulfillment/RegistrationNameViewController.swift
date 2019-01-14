import UIKit
import RxSwift
import RxOptional

class RegistrationNameViewController: UIViewController, RegistrationSubController {
    
    @IBOutlet var nameTextField: TextField!
    @IBOutlet var confirmButton: ActionButton!
    let finished = PublishSubject<Void>()
    
    lazy var viewModel: GenericFormValidationViewModel = {
        let nameIsValid = self.nameTextField.rx.text.asObservable().replaceNilWith("").map(isZeroLength).not()
        return GenericFormValidationViewModel(isValid: nameIsValid, manualInvocation: self.nameTextField.rx_returnKey, finishedSubject: self.finished)
    }()
    
    fileprivate let _viewWillDisappear = PublishSubject<Void>()
    var viewWillDisappear: Observable<Void> {
        return self._viewWillDisappear.asObserver()
    }
    
    lazy var bidDetails: BidDetails! = { self.navigationController!.fulfillmentNav().bidDetails }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.text = bidDetails.newUser.name.value
        nameTextField
            .rx.text
            .asObservable()
            .takeUntil(viewWillDisappear)
            .bind(to: bidDetails.newUser.name)
            .disposed(by: rx.disposeBag)
        
        confirmButton.rx.action = viewModel.command
        
        nameTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        _viewWillDisappear.onNext(Void())
    }
    class func instantiateFromStoryboard(_ storyboard: UIStoryboard) -> RegistrationMobileViewController {
        return storyboard.viewController(withID: .RegisterMobile) as! RegistrationMobileViewController
    }
}
