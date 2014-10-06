//    import Nimble
//
//    struct Snapshot {
//        let name: String
//
//        init(name: String) {
//            self.name = name
//        }
//    }
//
//    func snapshot(name: String) -> Snapshot {
//        return Snapshot(name: name)
//    }
//
//    func == <Snapshotable: Comparable> (lhs: Expectation<Snapshotable>, rhs: Snapshot) -> Bool {
//        lhs.to( haveValidSnapshot(named: rhs.name) )
//    }