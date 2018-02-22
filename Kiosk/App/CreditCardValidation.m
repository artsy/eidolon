#import "CreditCardValidation.h"

BOOL validateCreditCardNumber(NSString *cardNumber) {
    STPCardValidationState validationState =
    [STPCardValidator validationStateForNumber:cardNumber validatingCardBrand:NO];

    switch (validationState) {
        case STPCardValidationStateValid:
            return YES;
            break;
        default:
            return NO;
            break;
    }
}
