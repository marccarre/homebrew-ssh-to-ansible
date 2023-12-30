class S2a < Formula
  desc "Tool to convert a SSH configuration to an Ansible YAML inventory"
  homepage "https://github.com/marccarre/ssh-to-ansible"
  url "https://github.com/marccarre/ssh-to-ansible/archive/refs/tags/0.3.0.tar.gz"
  sha256 "b024c669d3cc232e86066f2205546a95997021e7acce03f98ed317e8fd913f38"
  license "Apache-2.0"
  head "https://github.com/marccarre/ssh-to-ansible.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    test_ssh_config = <<~EOF
      Host default
        HostName 127.0.0.1
        User vagrant
        Port 50022
        UserKnownHostsFile /dev/null
        StrictHostKeyChecking no
        PasswordAuthentication no
        IdentityFile /tmp/.vagrant/machines/default/private_key
        IdentitiesOnly yes
        LogLevel FATAL
        PubkeyAcceptedKeyTypes +ssh-rsa
        HostKeyAlgorithms +ssh-rsa
    EOF

    expected_output = <<~EOF
      local:
        hosts:
          default:
            ansible_host: 127.0.0.1
            ansible_port: 50022
            ansible_user: vagrant
            ansible_ssh_private_key_file: /tmp/.vagrant/machines/default/private_key
            ansible_ssh_extra_args: -o HostKeyAlgorithms=+ssh-rsa -o IdentitiesOnly=yes -o LogLevel=FATAL -o PasswordAuthentication=no -o PubkeyAcceptedKeyTypes=+ssh-rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
    EOF

    assert_equal expected_output, pipe_output("#{bin}/s2a", test_ssh_config)
  end
end
