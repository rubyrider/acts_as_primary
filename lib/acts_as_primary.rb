require "acts_as_primary/version"

module ActsAsPrimary

  #specify_primary_information({using: :primary_account, transaction: true}) { |account| account.user.payment_accounts }


  extend ActiveSupport::Concern

  included do
    before_validation :mark_as_primary
  end

  class_methods do
    def specify_primary_information(options={}, &block)
      @primary_marker = options[:using] || :primary
      @_revert_from_primary_list = block || -> { self.class.all }
      @_allow_transaction = options[:transaction] || true

      private
      define_method :mark_as_primary do
        _allow_transaction = self.class.instance_variable_get :@_allow_transaction
        deselect_as_primary!(get_records, _allow_transaction)
      end
    end
  end

  def deselect_as_primary!(records, transaction = false)
    column = find_marker_column
    _filtered_record = records.where(:"#{column}" => true)
    _filtered_record = _filtered_record.where.not(:id => self.id) if self.persisted?
    _update_as_non_primary = -> { _filtered_record.update_all({:"#{column}" => false}) }
    return _update_as_non_primary.call unless transaction
    ActiveRecord::Base.transaction do
      _update_as_non_primary.call
    end
  end

  def mark_primary!(transaction=true)
    column = find_marker_column
    self.deselect_as_primary!(get_records, transaction)
    self.update_attribute("#{column}", true)
  end

  private

  def get_records
    (self.class.instance_variable_get :@_revert_from_primary_list).call(self)
  end

  def find_marker_column
    self.class.instance_variable_get(:@primary_marker)
  end

  def set_as_primary!(column = nil)
    column = column || find_marker_column
    self.send "#{column}=", true
  end

end
