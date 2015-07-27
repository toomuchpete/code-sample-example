# Irrelevant parts of this class have been omitted for clarity

class NotificationMethod
    before_validation :strip_phonenumber, :downcase_target
    before_create :initialize_confirmation

    field :method
    field :target
    field :confirmed
    field :confirmation_code
    field :enabled
    field :label

    belongs_to :user

    validates :method, inclusion: {in: %w(email text), message: "Must be email or text message."}
    validate :valid_target
    validates_uniqueness_of :target, scope: :user_id, message: "You already have a notification method for this."

    # This method saves us from having to add a whole bunch of if/else blocks
    # to handle the three different states a notification method can have
    def status
        return :not_confirmed unless confirmed?
        return :disabled unless enabled?
        
        :enabled
    end

    private

    def strip_phonenumber
        self.target = target.gsub(/\D/, '') if method == 'text'
    end

    def downcase_target
        self.target = target.downcase
    end

    def initialize_confirmation
        # A user's account address is already confirmed, don't force another confirmation
        if target == @user.email_address
            self.confirmed = true
            self.enabled   = true
            return
        end

        self.confirmed = false
        self.enabled   = false

        if method == 'text'
            # We use shorter and more memorable confirmation codes for text messages
            self.confirmation_code = (SecureRandom.random_number(900000) + 100000).to_s
        else
            self.confirmation_code = SecureRandom.hex
        end
        
        # Send notification 
        NotificationConfirmationWorker.perform_async(@notification_method._id.to_s)
    end

    # A custom validation here makes sure that our phone numbers and emails
    # look something like they're supposed to.
    def valid_target
        if method == 'text'
            errors.add(:target, "That doesn't look like a phone number.") unless target.length == 10
        end

        if method == 'email'
            errors.add(:target, "That doesn't look like an email address.") unless target.include? '@'
        end
    end
end
