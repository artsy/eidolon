import RxSwift

extension Observable {
    func logError(prefix: String = "Error: ") -> Observable<Element> {
        return self.doOn { event in
            switch event {
            case .Error(let error):
                print("\(prefix)\(error)")
            default: break
            }
        }
    }
}