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

    func logServerError(message: String) -> Observable<Element> {
        return self.doOn { event in
            switch event {
            case .Error(let e):
                let error = e as NSError
                logger.log(message)
                logger.log("Error: \(error.localizedDescription). \n \(error.artsyServerError())")
            default: break
            }
        }
    }

    func logNext() -> Observable<Element> {
        return self.doOn { event in
            switch event {
            case .Next(let value):
                print("\(value)")
            default: break
            }
        }
    }
}
