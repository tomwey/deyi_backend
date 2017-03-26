class User < ActiveRecord::Base
  
  before_create :generate_uid
  def generate_uid
    begin
      n = rand(10)
      if n == 0
        n = 8
      end
      self.uid = (n.to_s + SecureRandom.random_number.to_s[2..8]).to_i
      # self.save!
    end while self.class.exists?(:uid => uid)
  end
  
  before_create :generate_private_token
  def generate_private_token
    self.private_token = SecureRandom.uuid.gsub('-', '') if self.private_token.blank?
  end
   
end
