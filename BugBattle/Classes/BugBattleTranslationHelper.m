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
            @"report_next": @"Siguiente",
            @"report_back": @"Atrás",
            @"report_cancel": @"Atrás",
            @"ok": @"Ok",
            @"report_sending": @"Sending your feedback...",
            @"report_sent": @"Gracias!",
            @"report_failed": @"Se ha producido un error.",
            @"report_failed_title": @"Error de conexión 🤕",
            @"mark_the_bug": @"Marque el problema",
            @"preparing_feedback": @"Un momento...",
        };
    }
    
    if ([lang isEqualToString: @"it"]) {
        return @{
            @"report_next": @"Avanti",
            @"report_back": @"Indietro",
            @"report_cancel": @"Chiudi",
            @"ok": @"Ok",
            @"report_sending": @"Invio feedback in corso...",
            @"report_sent": @"Grazie!",
            @"report_failed": @"Qualcosa è andato storto.",
            @"report_failed_title": @"Errore di connessione 🤕",
            @"mark_the_bug": @"Segna il problema",
            @"preparing_feedback": @"Un momento...",
        };
    }
    
    if ([lang isEqualToString: @"fr"]) {
        return @{
            @"report_next": @"Suivant",
            @"report_back": @"Retour",
            @"report_cancel": @"Fermer",
            @"ok": @"Ok",
            @"report_sending": @"Envoi de vos commentaires...",
            @"report_sent": @"Merci!",
            @"report_failed": @"Oups, il y a eu un problème.",
            @"report_failed_title": @"Erreur de connexion 🤕",
            @"mark_the_bug": @"Marquer le problème",
            @"preparing_feedback": @"Un moment...",
        };
    }
    
    if ([lang isEqualToString: @"de"]) {
        return @{
            @"report_next": @"Weiter",
            @"report_back": @"Zurück",
            @"report_cancel": @"Abbrechen",
            @"ok": @"Ok",
            @"report_sending": @"Feedback wird gesendet...",
            @"report_sent": @"Vielen Dank!",
            @"report_failed": @"Ups, da ist etwas schief gelaufen.",
            @"report_failed_title": @"Verbindungsfehler 🤕",
            @"mark_the_bug": @"Markiere das Problem",
            @"preparing_feedback": @"Einen Moment...",
        };
    }
    
    if ([lang isEqualToString: @"nl"]) {
        return @{
            @"report_next": @"Volgende",
            @"report_back": @"Terug",
            @"report_cancel": @"Annuleer",
            @"ok": @"Ok",
            @"report_sending": @"Uw feedback verzenden...",
            @"report_sent": @"Dank u!",
            @"report_failed": @"Oeps, er gaat helaas iets mis",
            @"report_failed_title": @"Verbindingsfout 🤕",
            @"mark_the_bug": @"Markeer het probleem",
            @"preparing_feedback": @"Een moment...",
        };
    }
    
    if ([lang isEqualToString: @"cz"]) {
        return @{
            @"report_next": @"Další",
            @"report_back": @"Zpět",
            @"report_cancel": @"Zrušit",
            @"ok": @"Ok",
            @"report_sending": @"Odesílání zpětné vazby ...",
            @"report_sent": @"Děkuji!",
            @"report_failed": @"Ups, něco se pokazilo.",
            @"report_failed_title": @"Chyba připojení 🤕",
            @"mark_the_bug": @"Označte problém",
            @"preparing_feedback": @"Moment...",
        };
    }
    
    return @{
        @"report_next": @"Next",
        @"report_back": @"Back",
        @"report_cancel": @"Cancel",
        @"ok": @"Ok",
        @"report_sending": @"Sending your feedback...",
        @"report_sent": @"Thank you!",
        @"report_failed": @"Ups, something went wrong.",
        @"report_failed_title": @"Connection error 🤕",
        @"mark_the_bug": @"Mark the issue",
        @"preparing_feedback": @"One moment...",
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
