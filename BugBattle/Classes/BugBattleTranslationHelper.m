//
//  BugBattleTranslationHelper.m
//  BugBattle
//
//  Created by Lukas Boehler on 17.02.21.
//

#import "BugBattleTranslationHelper.h"
#import "BugBattleCore.h"

@implementation BugBattleTranslationHelper

+ (NSDictionary *)getTranslation {
    NSString *lang = [[BugBattle sharedInstance].language lowercaseString];
    if (lang.length > 2) {
        lang = [lang substringToIndex: 2];
    }
    
    if ([lang isEqualToString: @"es"]) {
        return @{
            @"report_priority_low": @"Baja",
            @"report_priority_medium": @"Media",
            @"report_priority_high": @"Alta",
            @"report_description_placeholder": @"Describa el error",
            @"report_email_placeholder": @"Introduzca su dirección de correo electrónico",
            @"report_next": @"Siguiente",
            @"report_back": @"Atrás",
            @"report_cancel": @"Atrás",
            @"report_send": @"Enviar",
            @"report_title": @"Informar de un error",
            @"ok": @"Ok",
            @"sending_report": @"Enviar un informe de error.",
            @"report_sent": @"¡Gracias por informarnos del error!",
            @"report_failed": @"Se ha producido un error.",
            @"report_failed_title": @"Error",
            @"report_privacy_policy_description": @"He leído y estoy de acuerdo con",
            @"report_privacy_policy_title": @"política de privacidad",
            @"report_privacy_policy_alert_title": @"Política de privacidad",
            @"report_privacy_policy_alert": @"Lea y acepte la política de privacidad."
        };
    }
    
    if ([lang isEqualToString: @"it"]) {
        return @{
            @"report_priority_low": @"Bassa",
            @"report_priority_medium": @"Media",
            @"report_priority_high": @"Alta",
            @"report_description_placeholder": @"Descrivete il vostro problema",
            @"report_email_placeholder": @"Inserisci la tua mail",
            @"report_next": @"Avanti",
            @"report_back": @"Indietro",
            @"report_cancel": @"Chiudi",
            @"report_send": @"Invia",
            @"report_title": @"Segnalare un bug",
            @"ok": @"Ok",
            @"sending_report": @"Inviare il tuo bug report.",
            @"report_sent": @"Grazie per il tuo bug report!",
            @"report_failed": @"Qualcosa è andato storto.",
            @"report_failed_title": @"Error",
            @"report_privacy_policy_description": @"Ho letto e accetto la ",
            @"report_privacy_policy_title": @"politica sulla riservatezza",
            @"report_privacy_policy_alert_title": @"Politica sulla riservatezza",
            @"report_privacy_policy_alert": @"Si prega di leggere e accettare l'informativa sulla privacy."
        };
    }
    
    if ([lang isEqualToString: @"fr"]) {
        return @{
            @"report_priority_low": @"Faible",
            @"report_priority_medium": @"Moyenne",
            @"report_priority_high": @"Haute",
            @"report_description_placeholder": @"Décrivez votre problème",
            @"report_email_placeholder": @"Entrez votre adresse mail",
            @"report_next": @"Suivant",
            @"report_back": @"Retour",
            @"report_cancel": @"Fermer",
            @"report_send": @"Envoyer",
            @"report_title": @"Signaler un bug",
            @"ok": @"Ok",
            @"sending_report": @"Envoyer votre rapport de bug.",
            @"report_sent": @"Merci de votre rapport de bug!",
            @"report_failed": @"Oups, il y a eu un problème.",
            @"report_failed_title": @"Error",
            @"report_privacy_policy_description": @"J'ai lu et accepté les",
            @"report_privacy_policy_title": @"politique de confidentialité",
            @"report_privacy_policy_alert_title": @"Politique de confidentialité",
            @"report_privacy_policy_alert": @"Veuillez lire et accepter la politique de confidentialité."
        };
    }
    
    if ([lang isEqualToString: @"de"]) {
        return @{
            @"report_priority_low": @"Leicht",
            @"report_priority_medium": @"Mittel",
            @"report_priority_high": @"Schwer",
            @"report_description_placeholder": @"Beischreibe das Problem",
            @"report_email_placeholder": @"Gib deine Email ein",
            @"report_next": @"Weiter",
            @"report_back": @"Zurück",
            @"report_send": @"Senden",
            @"report_cancel": @"Abbrechen",
            @"report_title": @"Bug melden",
            @"ok": @"Ok",
            @"sending_report": @"Bug report wird gesendet.",
            @"report_sent": @"Vielen Dank!",
            @"report_failed": @"Ups, da ist etwas schief gelaufen.",
            @"report_failed_title": @"Error",
            @"report_privacy_policy_description": @"I have read and agree to the ",
            @"report_privacy_policy_title": @"privacy policy",
            @"report_privacy_policy_alert_title": @"Privacy policy",
            @"report_privacy_policy_alert": @"Please read and accept the privacy policy."
        };
    }
    
    return @{
        @"report_priority_low": @"Low",
        @"report_priority_medium": @"Medium",
        @"report_priority_high": @"High",
        @"report_description_placeholder": @"Describe your problem",
        @"report_email_placeholder": @"Enter your email",
        @"report_next": @"Next",
        @"report_back": @"Back",
        @"report_send": @"Send",
        @"report_cancel": @"Cancel",
        @"report_title": @"Report a bug",
        @"ok": @"Ok",
        @"sending_report": @"Sending your bug report.",
        @"report_sent": @"Thank you!",
        @"report_failed": @"Ups, something went wrong.",
        @"report_failed_title": @"Error",
        @"report_privacy_policy_description": @"I have read and agree to the ",
        @"report_privacy_policy_title": @"privacy policy",
        @"report_privacy_policy_alert_title": @"Privacy policy",
        @"report_privacy_policy_alert": @"Please read and accept the privacy policy."
    };
}

+ (NSString *)localizedString:(NSString *)string {
    NSDictionary *translation = BugBattleTranslationHelper.getTranslation;
    
    NSString *translatedString = [translation objectForKey: string];
    if (translatedString) {
        return translatedString;
    }
    
    return string;
}

@end
