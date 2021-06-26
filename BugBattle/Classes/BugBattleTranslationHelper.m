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
            @"report_sent": @"Gracias!",
            @"report_failed": @"Se ha producido un error.",
            @"report_failed_title": @"Error",
            @"mark_the_bug": @"Marque el problema",
        };
    }
    
    if ([lang isEqualToString: @"it"]) {
        return @{
            @"report_next": @"Avanti",
            @"report_back": @"Indietro",
            @"report_cancel": @"Chiudi",
            @"ok": @"Ok",
            @"report_sent": @"Grazie!",
            @"report_failed": @"Qualcosa è andato storto.",
            @"report_failed_title": @"Error",
            @"mark_the_bug": @"Segna il problema",
        };
    }
    
    if ([lang isEqualToString: @"fr"]) {
        return @{
            @"report_next": @"Suivant",
            @"report_back": @"Retour",
            @"report_cancel": @"Fermer",
            @"ok": @"Ok",
            @"report_sent": @"Merci!",
            @"report_failed": @"Oups, il y a eu un problème.",
            @"report_failed_title": @"Error",
            @"mark_the_bug": @"Marquer le problème",
        };
    }
    
    if ([lang isEqualToString: @"de"]) {
        return @{
            @"report_next": @"Weiter",
            @"report_back": @"Zurück",
            @"report_cancel": @"Abbrechen",
            @"ok": @"Ok",
            @"report_sent": @"Vielen Dank!",
            @"report_failed": @"Ups, da ist etwas schief gelaufen.",
            @"report_failed_title": @"Fehler",
            @"mark_the_bug": @"Markiere das Problem",
        };
    }
    
    if ([lang isEqualToString: @"nl"]) {
        return @{
            @"report_next": @"Volgende",
            @"report_back": @"Terug",
            @"report_cancel": @"Annuleer",
            @"ok": @"Ok",
            @"report_sent": @"Dank u!",
            @"report_failed": @"Oeps, er gaat helaas iets mis",
            @"report_failed_title": @"Fout",
            @"mark_the_bug": @"Markeer het probleem",
        };
    }
    
    if ([lang isEqualToString: @"cz"]) {
        return @{
            @"report_next": @"Další",
            @"report_back": @"Zpět",
            @"report_cancel": @"Zrušit",
            @"ok": @"Ok",
            @"report_sent": @"Děkuji!",
            @"report_failed": @"Ups, něco se pokazilo.",
            @"report_failed_title": @"Chyba",
            @"mark_the_bug": @"Označte problém",
        };
    }
    
    return @{
        @"report_next": @"Next",
        @"report_back": @"Back",
        @"report_cancel": @"Cancel",
        @"ok": @"Ok",
        @"report_sent": @"Thank you!",
        @"report_failed": @"Ups, something went wrong.",
        @"report_failed_title": @"Error",
        @"mark_the_bug": @"Mark the issue",
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
