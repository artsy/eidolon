import RxSwift

extension Observable {
    func logError(prefix: String = "Error: ") -> Observable<Element> {
        return self.doOn { event in
            switch event {
            case .error(let error):
                print("\(prefix)\(error)")
            default: break
            }
        }
    }

    func logServerError(message: String) -> Observable<Element> {
        return self.doOn { event in
            switch event {
            case .error(let e):
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
            case .next(let value):
                print("\(value)")
            default: break
            }
        }
    }
}
