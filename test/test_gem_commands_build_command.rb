require 'test/unit'
require 'test/gemutilities'
require 'rubygems/commands/build_command'

class TestGemCommandsBuildCommand < RubyGemTestCase

  def setup
    super

    @cmd = Gem::Commands::BuildCommand.new
  end

  def test_execute
    gem = quick_gem 'some_gem'

    gemspec_file = File.join(@tempdir, "#{gem.full_name}.gemspec")

    File.open gemspec_file, 'w' do |gs|
      gs.write gem.to_ruby
    end

    util_test_build_gem gem, gemspec_file
  end

  def test_execute_yaml
    gem = quick_gem 'some_gem'

    gemspec_file = File.join(@tempdir, "#{gem.full_name}.gemspec")

    File.open gemspec_file, 'w' do |gs|
      gs.write gem.to_yaml
    end

    util_test_build_gem gem, gemspec_file
  end

  def test_execute_bad_gem
    @cmd.options[:args] = %w[some_gem]
    use_ui @ui do
      @cmd.execute
    end

    assert_equal '', @ui.output
    assert_equal "ERROR:  Gemspec file not found: some_gem\n", @ui.error
  end

  def util_test_build_gem(gem, gemspec_file)
    @cmd.options[:args] = [gemspec_file]
    use_ui @ui do
      Dir.chdir @tempdir do
        @cmd.execute
      end
    end

    output = @ui.output.split "\n"
    assert_equal "  Successfully built RubyGem", output.shift
    assert_equal "  Name: some_gem", output.shift
    assert_equal "  Version: 0.0.2", output.shift
    assert_equal "  File: some_gem-0.0.2.gem", output.shift
    assert_equal [], output
    assert_equal '', @ui.error

    assert File.exist?(File.join(@tempdir, "#{gem.full_name}.gem"))
  end

end
