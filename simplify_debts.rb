class SimplifyDebts
  attr_reader :files, :debt

  def initialize(files)
    @files = files
    @debt = Hash.new(0)
  end

  def process
    calculate_debts
    adjust_debts
  end

  private

    def calculate_debts
      files.each do |file|
        process_files(file)
      end
    end

    def process_files(file)
      file_data = File.readlines(file).map(&:chomp)

      return if file_data.size <= 2

      total_expense = file_data[1].to_i
      members = file_data.size - 2
      expense_share = total_expense / members
      calculate_individual_expense(file_data, expense_share)
    end

    def calculate_individual_expense(file_data, expense_share)
      file_data[2..].each do |member|
        name, amt_paid = member.split
        debt[name] += amt_paid.to_i - expense_share
      end
    end

    def adjust_debts
      members_owed = debt.select { |_, amount| amount < 0 }.to_a
      members_getback = debt.select { |_, amount| amount > 0 }.to_a

      while members_owed.any? && members_getback.any?
        owed_member_name, owed_amount = members_owed.first
        getback_member_name, getback_amount = members_getback.first

        amount = [owed_amount.abs, getback_amount].min

        puts "#{owed_member_name} has to pay ₹#{amount} to #{getback_member_name}"

        members_owed[0] = [owed_member_name, owed_amount + amount]
        members_getback[0] = [getback_member_name, getback_amount - amount]

        members_owed.shift if members_owed.first[1] >= 0
        members_getback.shift if members_getback.first[1] <=0
      end
    end
end

files = ['exp_one.txt', 'exp_two.txt', 'exp_three.txt']
SimplifyDebts.new(files).process
