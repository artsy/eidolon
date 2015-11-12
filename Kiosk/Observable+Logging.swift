import RxSwift

extension Observable {
    func logError() -> Observable<Element> {
        return self.doOn { event in
            switch event {
            case .Error(let error):
                print("Error: \(error)")
            default: break
            }
        }
    }
}