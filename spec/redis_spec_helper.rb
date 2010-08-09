class RedisSpecHelper
  TEST_OPTIONS = {:db => 15}
  
  def self.reset   
    Ohm.connect(TEST_OPTIONS)
    Ohm.flush
  end
end
