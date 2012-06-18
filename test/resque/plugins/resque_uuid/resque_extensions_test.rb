require File.expand_path(File.join(File.dirname(__FILE__), "../../../test_helper"))

class FakeJobClass

  def self.after_uuid_generated(uuid, *args)
    @passed_uuid = uuid
    @passed_args = args
  end

  def self.passed_uuid
    @passed_uuid
  end

  def self.passed_args
    @passed_args
  end
end

class FakeJobClassNoUUIDCallback
end

class ResqueExtensionsTest < Test::Unit::TestCase
  class << self
    # we need to startup and shutdown a redis server for this test case so we can enqueue resque push/pop still work properly
    def startup
      startup_test_redis
    end

    def shutdown
      shutdown_test_redis
    end
  end

  setup do
    # clear out resque queues each run
    Resque.redis.flushall
  end

  should "add a uuid to job payload when pushed" do
    test_uuid = UUIDTools::UUID.random_create
    UUIDTools::UUID.stubs(:random_create).returns(test_uuid)

    fake_payload = { 'payload' => 'blah' }

    Resque.push :my_queue, fake_payload

    assert_equal fake_payload.merge('uuid' => test_uuid.to_s), Resque.pop(:my_queue)
  end

  should "call after_uuid_generated method defined on payload class" do
    test_uuid = UUIDTools::UUID.random_create
    UUIDTools::UUID.stubs(:random_create).returns(test_uuid)

    fake_payload = { 'class' => FakeJobClass.to_s, 'args' => [1,2,3] }

    Resque.push :my_queue, fake_payload

    assert_equal fake_payload.merge('uuid' => test_uuid.to_s), Resque.pop(:my_queue)
    assert_equal test_uuid.to_s, FakeJobClass.passed_uuid
    assert_equal [1,2,3], FakeJobClass.passed_args
  end

  should "not call after_uuid_generated if payload class doesn't define one" do
    test_uuid = UUIDTools::UUID.random_create
    UUIDTools::UUID.stubs(:random_create).returns(test_uuid)

    fake_payload = { 'class' => FakeJobClassNoUUIDCallback.to_s }

    assert_nothing_raised do
      Resque.push :my_queue, fake_payload
    end

    assert_equal fake_payload.merge('uuid' => test_uuid.to_s), Resque.pop(:my_queue)
  end

end
