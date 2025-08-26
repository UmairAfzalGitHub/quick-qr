//
//  Strings.swift
//  Quick QR
//
//  Created by Umair Afzal on 26/08/2025.
//

import Foundation

struct Strings {
    struct Settings {
        static var numberLocator: String { "number_locator".localized() }
    }
    
    struct Error {
        static var general: String { "general_error".localized() }
    }
    
    struct TextField {
        static var password: String { "password".localized() }
    }
    
    struct Label {
        static var numberLocator: String { "number_locator".localized() }
        static var findYourDesired: String { "find_your_desired".localized() }
        static var locateNow: String { "locate_now".localized() }
        static var contacts: String { "contacts".localized() }
        static var areaCode: String { "area_code".localized() }
        static var ipLookup: String { "ip_lookup".localized() }
        static var compass: String { "compass".localized() }
        static var findYourWay: String { "find_your_way".localized() }
        static var trackNow: String { "track_now".localized() }
        static var speedTest: String { "speed_test".localized() }
        static var home: String { "home".localized() }
        
        static var enterValidIp: String { "enter_a_valid_ip".localized() }
        static var noDataRecieved: String { "no_data_recieved".localized() }
        static var failedToParse: String { "failed_to_parse".localized() }
        static var noDataReceived: String { "no_data_received".localized() }
        static var location: String { "location".localized() }
        static var coordinates: String { "coordinates".localized() }
        static var isp: String { "isp".localized() }
        static var organization: String { "organization".localized() }
        static var timeZone: String { "time_zone".localized() }
        static var zipCode: String { "zip_code".localized() }
        
        static var upload: String { "upload".localized() }
        static var mbps: String { "mbps".localized() }
        static var download: String { "download".localized() }
        static var startTest: String { "start_test".localized() }
        static var stop: String { "stop".localized() }
        
        static var rateOurApp: String { "rate_our_app".localized() }
        static var loveToHear: String { "love_to_hear".localized() }
        
        static var earnRewardedLookups: String { "earn_rewarded_lookups".localized() }
        static var takeFewMoments: String { "take_few_moments".localized() }
        static var buyAdfreePremium: String { "buy_adfree_premium".localized() }
        static var getBoosted: String { "get_boosted".localized() }
        static var lookups: String { "lookups".localized() }
        static var lookup: String { "lookup".localized() }
        static var watch: String { "watch".localized() }
        static var adsEarn: String { "ads_earn".localized() }
        
        static var upgradeToPremium: String { "upgrade_to_premium".localized() }
        static var unlimitedSearch: String { "unlimited_search".localized() }
        static var fastSearch: String { "fast_search".localized() }
        static var accessToAll: String { "access_to_all".localized() }
        static var noAds: String { "no_ads".localized() }
        static var freeTrialEnabled: String { "free_trial_enabled".localized() }
        static var restorePurchase: String { "restore_purchase".localized() }
        static var manageSubscription: String { "manage_subscription".localized() }
        static var privacyPolicy: String { "privacy_policy".localized() }
        static var tryForFree: String { "try_for_free".localized() }
        static var continueString: String { "continue".localized() }
        static var threeDayTrial: String { "three_day_trial".localized() }
        static var then: String { "then".localized() }
        static var perWeek: String { "per_week".localized() }
        static var monthlyPremium: String { "monthly_premium".localized() }
        static var perMonth: String { "per_month".localized() }
        static var autoRenewal: String { "auto_renewal".localized() }
        static var saveFifty: String { "save_fifty".localized() }
        static var weDontTrack: String { "we_dont_track".localized() }
        static var forFurtherInfo: String { "for_further_info".localized() }
        static var agreeAndContinue: String { "agree_and_continue".localized() }
        static var phoneNumberLocator: String { "phone_number_locator".localized() }
        static var pleaseEnterValid: String { "please_enter_valid".localized() }
        static var loadingAd: String { "loading_ad".localized() }
        static var problemShowingAd: String { "problem_showing_ad".localized() }
        static var congratsYouEarned: String { "congrats_you_earned".localized() }
        static var lookupsForHours: String { "lookups_for_hours".localized() }
        static var effortlessly: String { "effortlessly".localized() }
        static var callerIdentification: String { "caller_identification".localized() }
        static var uncoverCallersIdentity: String { "uncover_callers_identity".localized() }
        static var searchNumbers: String { "search_numbers".localized() }
        static var noMoreGuesswork: String { "no_more_guesswork".localized() }
        static var yourReviewMatters: String { "your_review_matters".localized() }
        static var weAreConstantlyWorking: String { "we_are_constantly_working".localized() }
        static var noNumber: String { "no_number".localized() }
        static var searchByCity: String { "search_by_city".localized() }
        static var copiedToClipboard: String { "copied_to_clipboard".localized() }
        static var title: String { "title".localized() }
        static var value: String { "value".localized() }
        static var sortByName: String { "sort_by_name".localized() }
        static var sortByCode: String { "sort_by_code".localized() }
        static var search: String { "search".localized() }
        static var accessAllFeatures: String { "access_all_features".localized() }
        static var upgradeToPro: String { "upgrade_to_pro".localized() }
        static var getPro: String { "get_pro".localized() }
        static var rateUs: String { "rate_us".localized() }
        static var lanuguage: String { "lanuguage".localized() }
        static var shareApp: String { "share_app".localized() }
        static var feedback: String { "feedback".localized() }
        static var termsAndConditions: String { "terms_and_conditions".localized() }
        static var settings: String { "settings".localized() }
        static var searchNumber: String { "search_number".localized() }
        static var enterPhoneNumber: String { "enter_phone_number".localized() }
        static var whichFeature: String { "which_feature".localized() }
        static var interest: String { "interest".localized() }
        static var next: String { "next".localized() }
        static var free: String { "free".localized() }
        static var angle: String { "angle".localized() }
        static var selectLanguage: String { "select_language".localized() }
        static var experienceTheBest: String { "experience_the_best".localized() }
        static var call: String { "call".localized() }
        static var sms: String { "sms".localized() }
        static var add: String { "add".localized() }
        static var block: String { "block".localized() }
        static var selectCountry: String { "select_country".localized() }
    }
    
    struct Button {
        static var save: String { "save".localized() }
        static var stop: String { "stop".localized() }
        static var continueLabel: String { "continue".localized() }
    }
    
    struct Messages {
        static var ok: String { "ok".localized() }
        static var done: String { "done".localized() }
        static var close: String { "close".localized() }
        static var error: String { "error".localized() }
        static var success: String { "success".localized() }
        static var restoredSuccessfully: String { "restoredSuccessfully".localized() }
        static var restoredFailed: String { "restoredFailed".localized() }
        static var unableToLoad: String { "unableToLoad".localized() }
        static var thankyouForSubscribing: String { "thankyouForSubscribing".localized() }
        static var failedToConnect: String { "failedToConnect".localized() }
        static var noActiveSubscription: String { "noActiveSubscription".localized() }
        static var noInternet: String { "no_internet".localized() }
    }
    
    struct TabBar {
        static var home: String { "home".localized() }
        static var servers: String { "servers".localized() }
        static var speedTest: String { "speedTest".localized() }
        static var more: String { "more".localized() }
    }
}

extension String {
    func localized(comment: String = "") -> String {
        // Route through LanguageManager so it uses the selected in-app language bundle
        return LanguageManager.localizedString(forKey: self)
    }
}
