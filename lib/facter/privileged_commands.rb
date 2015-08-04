# Fact: :privileged_commands
#
# Purpose: retrieve array of files with setuid or setgid set
#
#
# Default for non-Linux nodes
#
Facter.add(:privileged_commands) do
    setcode do
        nil
    end
end

# Linux
#
Facter.add(:privileged_commands) do
    confine :kernel  => :linux
    setcode do
        command_list = [Facter::Util::Resolution.exec('find / -xdev -type f -perm -4000 -o -perm -2000 2>/dev/null']
    end
end

