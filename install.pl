#!/usr/bin/env perl

use strict;
use warnings;

use Cwd qw( abs_path );
use File::Basename qw( fileparse dirname );
use File::Slurp qw( slurp write_file );
use File::Copy qw( copy );

# inspired by install.sh in http://github.com/jferris/config_files

my $local_config_pattern = qr/(START LOCAL CONFIGURATION[^\n]*\n.*?[^\n*]END LOCAL CONFIGURATION)/ms;

my $target_dir = abs_path(shift or $ENV{HOME});
$target_dir =~ s/\/$//;

die "$target_dir is not a directory that exists" if !-d $target_dir;
die "nope" if $target_dir eq abs_path $ENV{HOME};

my $can_symlink = eval { symlink('', ''); 1 };

my ($script_name, $repos_dir) = fileparse abs_path $0;
$repos_dir =~ s/\/$//;

opendir(my $dir_handle, $repos_dir) or die "Couldn't open directory: $!";
my @files = readdir $dir_handle;
closedir $dir_handle;

for my $filename (@files) {
	next if $filename =~ /^\./;              # skip dot files
	next if -d $filename;                    # skip directories
	next if $filename eq $script_name;       # skip install file

	my $source_file = "$repos_dir/$filename";
	my $target_file = "$target_dir/.$filename";

	# get the local configuration section if there is one
	my $source_content = slurp $source_file;
	my $target_content = slurp $target_file;

	my ($source_local_config) = $source_content =~ /$local_config_pattern/;
	my ($target_local_config) = $target_content =~ /$local_config_pattern/;

	if (!-e $target_file) {
		print "creating $target_file\n";
		if ($can_symlink and !$source_local_config) {
			symlink $source_file => $target_file;
		} else {
			copy $source_file => $target_file;
		}
	} elsif (-l $target_file and $source_local_config) {
		# when a file gets a config section added to it,
		# remove the symlink and replace it with a file copy
		print "replacing $target_file\n";
		unlink $target_file;
		copy $source_file => $target_file;
	} elsif (!-l $target_file) {
		my $new_content = slurp $source_file;
		$new_content =~ s/$local_config_pattern/$target_local_config/;

		# if there are differences, copy the new content into place
		if ($target_content ne $new_content) {
			print "updating $target_file\n";
			write_file $target_file => $new_content;
		} else {
			warn "$target_file is the same as $source_file but is not a symlink" if !$target_local_config;
		}
	}
}
