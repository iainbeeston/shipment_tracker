require 'rugged'

require 'git_repository'

class GitRepositoryLoader
  def initialize(ssh_key:, ssh_user:, cache_dir: Dir.tmpdir)
    @ssh_key = ssh_key
    @ssh_user = ssh_user
    @cache_dir = cache_dir
  end

  def load(repository_name)
    remote_repository = RepositoryLocation.find_by_name(repository_name)
    uri = remote_repository.uri
    dir = File.join(cache_dir, "#{remote_repository.id}-#{repository_name}")

    options_for(uri) do |options|
      repository = updated_rugged_repository(uri, dir, options)
      GitRepository.new(repository)
    end
  end

  private

  attr_reader :cache_dir, :ssh_user, :ssh_key

  def updated_rugged_repository(uri, dir, options)
    Rugged::Repository.new(dir, options).tap do |r|
      r.fetch('origin', options)
    end
  rescue Rugged::OSError, Rugged::RepositoryError
    Rugged::Repository.clone_at(uri, dir, options)
  end

  def options_for(uri, &block)
    case URI.parse(uri).scheme
    when 'ssh'
      options_for_ssh(&block)
    else
      block.call({})
    end
  end

  def options_for_ssh(&block)
    fail 'ssh_user not set' unless ssh_user
    fail 'ssh_key not set' unless ssh_key

    ssh_key_file = Tempfile.new('key', cache_dir)
    ssh_key_file.write(ssh_key)
    ssh_key_file.close

    block.call(
      credentials: Rugged::Credentials::SshKey.new(
        username: ssh_user,
        privatekey: ssh_key_file.path,
      ),
    )
  ensure
    ssh_key_file.unlink if ssh_key_file
  end
end
