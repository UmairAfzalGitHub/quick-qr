
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
        static var areaCode: String { "area_code".localized() }
        static var searchByCity: String { "search_by_city".localized() }
        static var copiedToClipboard: String { "copied_to_clipboard".localized() }
        static var search: String { "search".localized() }
        static var sortByName: String { "sort_by_name".localized() }
        static var sortByCode: String { "sort_by_code".localized() }
        static var title: String { "title".localized() }
        static var value: String { "value".localized() }
        static var barCodeName: String { "bar_code_name".localized() }
        static var enterCode: String { "enter_code".localized() }
        static var barCode: String { "bar_code".localized() }
        static var enterATitle: String { "enter_a_title".localized() }
        static var location: String { "location".localized() }
        static var pleaseEnterSomething: String { "please_enter_something".localized() }
        static var allDay: String { "all_day".localized() }
        static var startTime: String { "start_time".localized() }
        static var endTime: String { "end_time".localized() }
        static var description: String { "description".localized() }
        static var name: String { "name".localized() }
        static var enterName: String { "enter_name".localized() }
        static var phoneNumber: String { "phone_number".localized() }
        static var enterPhoneNumber: String { "enter_phone_number".localized() }
        static var emailAddress: String { "email_address".localized() }
        static var enterEmailAddress: String { "enter_email_address".localized() }
        static var subject: String { "subject".localized() }
        static var content: String { "content".localized() }
        static var userName: String { "user_name".localized() }
        static var enterUserName: String { "enter_user_name".localized() }
        static var url: String { "url".localized() }
        static var enterUrl: String { "enter_url".localized() }
        static var latitude: String { "latitude".localized() }
        static var longitude: String { "longitude".localized() }
        static var enterLatitudeLocation: String { "enter_latitude_location".localized() }
        static var enterLongitudeLocation: String { "enter_longitude_location".localized() }
        static var textMessage: String { "text_message".localized() }
        static var websiteUrl: String { "website_url".localized() }
        static var whatsAppNumber: String { "whatsApp_number".localized() }
        static var networkNameSSID: String { "network_name_ssid".localized() }
        static var enterSSID: String { "enter_ssid".localized() }
        static var password: String { "password".localized() }
        static var enterPassword: String { "enter_password".localized() }
        static var securityMode: String { "security_mode".localized() }
        static var none: String { "none".localized() }
        static var share: String { "share".localized() }
        static var save: String { "save".localized() }
        static var create: String { "create".localized() }
        static var error: String { "error".localized() }
        static var failedToGenerate: String { "failed_to_generate".localized() }
        static var telColon: String { "tel_colon".localized() }
        static var smsToColon: String { "sms_to_colon".localized() }
        static var wifiName: String { "wifi_name".localized() }
        static var sms: String { "sms".localized() }
        static var toColon: String { "to_colon".localized() }
        static var text: String { "text".localized() }
        static var contact: String { "contact".localized() }
        static var email: String { "email".localized() }
        static var website: String { "website".localized() }
        static var geoCoordinates: String { "geo_coordinates".localized() }
        static var calendarEvent: String { "calendar_event".localized() }
        static var success: String { "success".localized() }
        static var imageSavedToLibrary: String { "image_saved_to_library".localized() }
        static var ok: String { "ok".localized() }
        static var failedToSaveImage: String { "failed_to_save_image".localized() }
        static var smartScanQrCode: String { "smart_scan_qr_code".localized() }
        static var pointYourCamera: String { "point_your_camera".localized() }
        static var easilyReadBarcodes: String { "easily_read_barcodes".localized() }
        static var easilyScanBarcodes: String { "easily_scan_barcodes".localized() }
        static var quicklyCreateQrCode: String { "quickly_create_qr_code".localized() }
        static var generateCustomQr: String { "generate_custom_qr".localized() }
        static var quickQR: String { "quick_qr".localized() }
        static var scanInstantly: String { "scan_instantly".localized() }
        static var next: String { "next".localized() }

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
