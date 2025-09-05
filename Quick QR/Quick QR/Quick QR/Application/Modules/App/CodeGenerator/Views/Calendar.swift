
import UIKit

final class CalendarView: UIView {
    // MARK: - Date Formatters
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    // MARK: - Public API
    var titleText: String? {
        get { titleTextField.text }
        set { titleTextField.text = newValue }
    }
    
    var locationText: String? {
        get { locationTextField.text }
        set { locationTextField.text = newValue }
    }
    
    var dayStartText: String? {
        get { contentTextView.text.isEmpty ? nil : contentTextView.text }
        set {
            contentTextView.text = newValue
            updateContentPlaceholder()
        }
    }
    
    var dayEndText: String? {
        get { contentTextView.text.isEmpty ? nil : contentTextView.text }
        set {
            contentTextView.text = newValue
            updateContentPlaceholder()
        }
    }
    
    // MARK: - Getter Methods
    func getTitle() -> String? {
        return titleTextField.text
    }
    
    func getLocation() -> String? {
        return locationTextField.text
    }
    
    func isAllDay() -> Bool {
        return allDaySwitch.isOn
    }
    
    func getStartDate() -> Date? {
        return startDatePicker.date
    }
    
    func getStartDateString() -> String? {
        return startTextField.text
    }
    
    func getEndDate() -> Date? {
        return endDatePicker.date
    }
    
    func getEndDateString() -> String? {
        return endTextField.text
    }
    
    func getDescription() -> String? {
        return contentTextView.text.isEmpty ? nil : contentTextView.text
    }
    
    // MARK: - Setter Methods
    func setTitle(_ title: String) {
        titleTextField.text = title
    }
    
    func setLocation(_ location: String) {
        locationTextField.text = location
    }
    
    func setAllDay(_ isAllDay: Bool) {
        allDaySwitch.isOn = isAllDay
        allDaySwitchChanged(allDaySwitch)
    }
    
    func setStartDate(_ date: Date) {
        startDatePicker.date = date
        updateDateFields()
    }
    
    func setEndDate(_ date: Date) {
        endDatePicker.date = date
        updateDateFields()
    }
    
    func setDescription(_ description: String) {
        contentTextView.text = description
        updateContentPlaceholder()
    }
    
    // MARK: - Data Population Methods
    func populateData(title: String, location: String = "", isAllDay: Bool = false, startDate: Date? = nil, endDate: Date? = nil, description: String = "") {
        setTitle(title)
        setLocation(location)
        setAllDay(isAllDay)
        
        if let startDate = startDate {
            setStartDate(startDate)
        }
        
        if let endDate = endDate {
            setEndDate(endDate)
        } else if let startDate = startDate {
            // Default end date is 1 hour after start date
            let defaultEndDate = Calendar.current.date(byAdding: .hour, value: 1, to: startDate) ?? startDate
            setEndDate(defaultEndDate)
        }
        
        setDescription(description)
    }
    
    /// Parse and populate calendar event data from a QR code content string
    /// - Parameter content: The calendar event content string (BEGIN:VEVENT...END:VEVENT)
    /// - Returns: True if the content was successfully parsed, false otherwise
    @discardableResult
    func parseAndPopulateFromContent(_ content: String) -> Bool {
        if content.hasPrefix("BEGIN:VEVENT") {
            let lines = content.components(separatedBy: .newlines)
            var title = ""
            var location = ""
            var description = ""
            var startDate: Date?
            var endDate: Date?
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
            
            for line in lines {
                if line.hasPrefix("SUMMARY:") {
                    title = String(line.dropFirst(8))
                } else if line.hasPrefix("LOCATION:") {
                    location = String(line.dropFirst(9))
                } else if line.hasPrefix("DESCRIPTION:") {
                    description = String(line.dropFirst(12))
                } else if line.hasPrefix("DTSTART:") {
                    let dateString = String(line.dropFirst(8))
                    startDate = dateFormatter.date(from: dateString)
                } else if line.hasPrefix("DTEND:") {
                    let dateString = String(line.dropFirst(6))
                    endDate = dateFormatter.date(from: dateString)
                }
            }
            
            // Check if we have at least a title and start date
            if let startDate = startDate {
                populateData(
                    title: title,
                    location: location,
                    isAllDay: false,
                    startDate: startDate,
                    endDate: endDate,
                    description: description
                )
                return true
            }
        }
        return false
    }
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Strings.Label.title
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .textPrimary
        return label
    }()
    
    private let titleTextField: UITextField = {
        let tf = PaddedTextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = Strings.Label.enterATitle
        tf.keyboardType = .namePhonePad
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.clearButtonMode = .whileEditing
        tf.backgroundColor = .systemBackground
        tf.layer.cornerRadius = 10
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.appBorderDark.cgColor
        return tf
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Strings.Label.location
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .textPrimary
        return label
    }()
    
    private let locationTextField: UITextField = {
        let tf = PaddedTextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = Strings.Label.pleaseEnterSomething
        tf.autocapitalizationType = .sentences
        tf.autocorrectionType = .no
        tf.backgroundColor = .systemBackground
        tf.layer.cornerRadius = 10
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.appBorderDark.cgColor
        return tf
    }()
    
    private let allDayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Strings.Label.allDay
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .textPrimary
        return label
    }()
    
    private let allDaySwitch: UISwitch = {
        let switchToogle = UISwitch()
        switchToogle.translatesAutoresizingMaskIntoConstraints = false
        switchToogle.backgroundColor = .clear
        switchToogle.onTintColor = .appPrimary
        return switchToogle
    }()
    
    private let startTextField: UITextField = {
        let tf = PaddedTextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = Strings.Label.startTime
        tf.autocapitalizationType = .sentences
        tf.autocorrectionType = .no
        tf.backgroundColor = .systemBackground
        tf.layer.cornerRadius = 10
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.appBorderDark.cgColor
        tf.inputView = UIDatePicker() // Will be configured in setup
        return tf
    }()
    
    private let endTextField: UITextField = {
        let tf = PaddedTextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = Strings.Label.endTime
        tf.autocapitalizationType = .sentences
        tf.autocorrectionType = .no
        tf.backgroundColor = .systemBackground
        tf.layer.cornerRadius = 10
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.appBorderDark.cgColor
        tf.inputView = UIDatePicker() // Will be configured in setup
        return tf
    }()
    
    private lazy var startDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .wheels
        picker.minimumDate = Date()
        picker.addTarget(self, action: #selector(startDateChanged(_:)), for: .valueChanged)
        return picker
    }()
    
    private lazy var endDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .wheels
        picker.minimumDate = Date()
        picker.addTarget(self, action: #selector(endDateChanged(_:)), for: .valueChanged)
        return picker
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Strings.Label.description
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .textPrimary
        return label
    }()
    
    private let contentContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .systemBackground
        v.layer.cornerRadius = 10
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.appBorderDark.cgColor
        return v
    }()
    
    private let contentTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.textColor = .label
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        tv.isScrollEnabled = true
        return tv
    }()
    
    private let contentPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Strings.Label.description
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.placeholderText
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - Private
    private func setup() {
        backgroundColor = .clear
        
        addSubview(titleLabel)
        addSubview(titleTextField)
        addSubview(locationLabel)
        addSubview(locationTextField)
        addSubview(allDayLabel)
        addSubview(allDaySwitch)
        addSubview(startTextField)
        addSubview(endTextField)
        addSubview(descriptionLabel)
        addSubview(contentContainer)
        contentContainer.addSubview(contentTextView)
        contentContainer.addSubview(contentPlaceholderLabel)
        
        contentTextView.delegate = self
        
        // Configure date pickers
        startTextField.inputView = startDatePicker
        endTextField.inputView = endDatePicker
        
        // Set initial dates
        let now = Date()
        startDatePicker.date = now
        endDatePicker.date = Calendar.current.date(byAdding: .hour, value: 1, to: now) ?? now
        updateDateFields()
        
        // Add toolbar with Done button
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([flexSpace, doneButton], animated: false)
        
        startTextField.inputAccessoryView = toolBar
        endTextField.inputAccessoryView = toolBar
        
        // Add all-day switch action
        allDaySwitch.addTarget(self, action: #selector(allDaySwitchChanged), for: .valueChanged)
        
        let side: CGFloat = 0
        let fieldHeight: CGFloat = 54
        let sectionSpacing: CGFloat = 16
        let labelFieldSpacing: CGFloat = 8
        
        NSLayoutConstraint.activate([
            // title label
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -side),
            titleLabel.heightAnchor.constraint(equalToConstant: 24),
            
            // title field
            titleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: labelFieldSpacing),
            titleTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            titleTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -side),
            titleTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            // location label
            locationLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: sectionSpacing),
            locationLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            locationLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -side),
            locationLabel.heightAnchor.constraint(equalToConstant: 24),
            

            // location field
            locationTextField.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: labelFieldSpacing),
            locationTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            locationTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -side),
            locationTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            // all Day label
            allDayLabel.topAnchor.constraint(equalTo: locationTextField.bottomAnchor, constant: sectionSpacing),
            allDayLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            allDayLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -side),
            allDayLabel.heightAnchor.constraint(equalToConstant: 24),
            
            allDaySwitch.centerYAnchor.constraint(equalTo: allDayLabel.centerYAnchor),
            allDaySwitch.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            
            startTextField.topAnchor.constraint(equalTo: allDayLabel.bottomAnchor, constant: labelFieldSpacing),
            startTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            startTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -side),
            startTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            endTextField.topAnchor.constraint(equalTo: startTextField.bottomAnchor, constant: labelFieldSpacing),
            endTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            endTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -side),
            endTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            // Content label
            descriptionLabel.topAnchor.constraint(equalTo: endTextField.bottomAnchor, constant: sectionSpacing),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            descriptionLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -side),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 24),
            
            // Content container
            contentContainer.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: labelFieldSpacing),
            contentContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            contentContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -side),
            contentContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 140),
            contentContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Text view inside container
            contentTextView.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            contentTextView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            contentTextView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            contentTextView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
            
            // Placeholder label inside container (aligned with text inset)
            contentPlaceholderLabel.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: 12),
            contentPlaceholderLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 16),
            contentPlaceholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentContainer.trailingAnchor, constant: -16)
        ])
        
        updateContentPlaceholder()
    }
    
    private func updateContentPlaceholder() {
        contentPlaceholderLabel.isHidden = !(contentTextView.text?.isEmpty ?? true)
    }
    
    private func updateDateFields() {
        if allDaySwitch.isOn {
            // Format as date only for all-day events
            let dateOnlyFormatter = DateFormatter()
            dateOnlyFormatter.dateStyle = .medium
            dateOnlyFormatter.timeStyle = .none
            startTextField.text = dateOnlyFormatter.string(from: startDatePicker.date)
            endTextField.text = dateOnlyFormatter.string(from: endDatePicker.date)
        } else {
            // Format with date and time
            startTextField.text = dateFormatter.string(from: startDatePicker.date)
            endTextField.text = dateFormatter.string(from: endDatePicker.date)
        }
    }
    
    // MARK: - Actions
    
    @objc private func startDateChanged(_ sender: UIDatePicker) {
        // If start date is after end date, update end date
        if sender.date > endDatePicker.date {
            endDatePicker.date = Calendar.current.date(byAdding: .hour, value: 1, to: sender.date) ?? sender.date
        }
        updateDateFields()
    }
    
    @objc private func endDateChanged(_ sender: UIDatePicker) {
        // If end date is before start date, update start date
        if sender.date < startDatePicker.date {
            startDatePicker.date = sender.date
        }
        updateDateFields()
    }
    
    @objc private func doneButtonTapped() {
        // Dismiss keyboard
        endEditing(true)
    }
    
    @objc private func allDaySwitchChanged(_ sender: UISwitch) {
        // Update date picker mode based on all-day switch
        if sender.isOn {
            startDatePicker.datePickerMode = .date
            endDatePicker.datePickerMode = .date
        } else {
            startDatePicker.datePickerMode = .dateAndTime
            endDatePicker.datePickerMode = .dateAndTime
        }
        updateDateFields()
    }
}

// MARK: - UITextViewDelegate
extension CalendarView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateContentPlaceholder()
    }
}

// MARK: - Helpers
/// A UITextField subclass that adds horizontal padding to match the design.
private final class PaddedTextField: UITextField {
    private let padding = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
}
