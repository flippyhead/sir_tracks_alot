class RedisSpecHelper
  TEST_OPTIONS = {:db => 13}
  
  def self.reset   
    Ohm.connect(TEST_OPTIONS)
    Ohm.flush
  end
end
