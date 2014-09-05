//
//  ListViewControllerTests.swift
//  Kiosk
//
//  Created by Orta on 9/5/14.
//  Copyright (c) 2014 Artsy. All rights reserved.
//


import Quick
import Nimble
import Kiosk

class ListingsViewControllerSpec: QuickSpec {
    override func spec() {
        
        describe("in some context", { () -> () in
            it("presents a view controller when showModal is called") {
                let sut = ListingsViewController()
                sut.allowAnimations = false;
                sut.showModal("")
                expect(sut).to(haveValidSnapshot())
            }
            
        });
    }
}
