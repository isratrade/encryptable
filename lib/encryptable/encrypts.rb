module Encryptable
  module Encrypts

    extend ActiveSupport::Concern

    included do
      before_save :encrypt_setters,  :if => "SETTINGS[:encryption_key].present?"
    end

    def encrypt_setters
      (Array(self.try(:encrypts_fields)) + Array(self.try(:encrypts_and_decrypts_fields))).each do |field|
        if send("#{field}_changed?")
          self.send("#{field}=", encrypt_field(send(field.to_sym)))
        end
      end
    end

    def encrypt_field(str)
      return str if SETTINGS[:encryption_key].blank?
      # TODO - return if already encrypted
      encryptor = ActiveSupport::MessageEncryptor.new(SETTINGS[:encryption_key])
      begin
        encryptor.encrypt_and_sign(str)
      rescue
        str
      end
    end

    def decrypt_field(str)
      return str if SETTINGS[:encryption_key].blank?
      encryptor = ActiveSupport::MessageEncryptor.new(SETTINGS[:encryption_key])
      begin
        encryptor.decrypt_and_verify(str)
      rescue ActiveSupport::MessageVerifier::InvalidSignature
        logger.info "Encryption Signature was Invalid.  String was not decrypted."
        str
      end
    end

    module ClassMethods

      # encrypts requires a manual {field}_decrypt method
      def encrypts(*fields)
        options = fields.extract_options!
        set_class_attributes
        set_encrypts_fields(fields.map(&:to_sym), options)
        set_magic_getters(fields.map(&:to_sym), options)
      end

      # encrypts_and_decrypts saved the data encrypted in the database, but getter method
      # always decrypts the field, so no {field}_decrypted method is required
      def encrypts_and_decrypts(*fields)
        options = fields.extract_options!
        set_class_attributes
        set_encrypts_and_decrypts_fields(fields.map(&:to_sym), options)
        set_magic_getters(fields.map(&:to_sym), options)
        set_auto_decrypt_getters(fields.map(&:to_sym), options)
      end

      def encrypts?(field)
        encrypts_fields.include?(field.to_sym) || encrypts_and_decrypts_fields.include?(field.to_sym)
      end

      #private

      def set_class_attributes
        #return if respond_to?(:encrypts_fields)
        class_attribute :encrypts_fields
        class_attribute :encrypts_and_decrypts_fields
      end

      def set_encrypts_fields(fields, options)
        self.encrypts_fields = Array.wrap(fields)
        self.encrypts_and_decrypts_fields ||= []
      end

      def set_encrypts_and_decrypts_fields(fields, options)
        self.encrypts_and_decrypts_fields = Array.wrap(fields)
        self.encrypts_fields ||= []
      end

      def set_magic_getters(fields, options)
        fields.each do |field|
          define_method "#{field}_decrypted" do
            decrypt_field(send(field.to_sym))
          end
          define_method "#{field}_encrypted" do
            encrypt_field(send(field.to_sym))
          end
        end
      end

      def set_auto_decrypt_getters(fields,options)
        fields.each do |field|
          #return unless self.column_names.include? field.to_s
          #alias_method "#{field}_encrypted".to_sym, field.to_sym

          define_method "#{field}" do
            decrypt_field(read_attribute(field.to_sym))
          end

        end
      end

    end

  end
end

ActiveRecord::Base.send :include, Encryptable::Encrypts
