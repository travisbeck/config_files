#!/usr/bin/env perl

use strict;
use warnings;

# only use modules in the base distribution for maximum portability
use Cwd qw( abs_path );
use File::Basename qw( fileparse dirname );
use File::Copy qw( copy );
use File::Path qw( mkpath );

# inspired by install.sh in http://github.com/jferris/config_files

my $local_config_pattern = qr/([^\n]*START LOCAL CONFIGURATION[^\n]*\n.*?[^\n*]END LOCAL CONFIGURATION[^\n]*\n)/ms;

my $target_dir = abs_path(shift or $ENV{HOME});
$target_dir =~ s/\/$//;

die "$target_dir is not a directory that exists" if !-d $target_dir;

my $can_symlink = eval { symlink('', ''); 1 };

my ($script_name, $repos_dir) = fileparse abs_path $0;
$repos_dir =~ s/\/$//;

for my $filename (list($repos_dir)) {
	next if $filename eq $script_name;    # skip this install file

	my $source_file = "$repos_dir/$filename";
	my $target_file = "$target_dir/.$filename";

	# get the local configuration section if there is one
	my ($source_local_config) = read_file($source_file) =~ /$local_config_pattern/ if -f $source_file;

	if (!-e $target_file) {
		print "creating $target_file\n";

		# make sure the directory exists
		mkpath dirname $target_file;

		if ($can_symlink and !$source_local_config) {
			symlink($source_file, $target_file);
		} else {
			copy($source_file, $target_file);
		}
	} elsif (-l $target_file and $source_local_config) {
		# when a file gets a config section added to it,
		# remove the symlink and replace it with a file copy
		print "replacing $target_file\n";
		unlink $target_file;
		copy($source_file, $target_file);
	} elsif (!-l $target_file) {
		my $target_content = read_file($target_file);
		my ($target_local_config) = $target_content =~ /$local_config_pattern/;

		my $new_content = read_file($source_file);
		if ($new_content !~ s/$local_config_pattern/$target_local_config/ and $target_local_config) {
			# make sure the target local config gets in there somehow
			$new_content =~ s/\A/$target_local_config/;
		}

		# if there are differences, copy the new content into place
		if ($target_content ne $new_content) {
			print "updating $target_file\n";
			if ($target_local_config) {
				write_file($target_file, $new_content);
			} else {
				unlink $target_file;
				symlink($source_file, $target_file);
			}
		} elsif (!$target_local_config) {
			print "$target_file is the same as $source_file but is not a symlink, replacing with symlink\n";
			unlink $target_file;
			symlink($source_file, $target_file);
		}
	}
}

# recursively list the contents of a directory
sub list {
	my ($dir, $is_recursive) = @_;
	return $dir if !-d $dir;

	opendir(my $dir_handle, $dir) or die "Couldn't open directory '$dir': $!";

	my @files;
	for my $filename (readdir $dir_handle) {
		next if $filename =~ /^\./;

		if (-d "$dir/$filename") {
			push(@files, map { "$filename/$_" } list("$dir/$filename"));
		} else {
			push(@files, $filename);
		}
	}

	closedir $dir_handle;
	return @files;
}

sub read_file {
	my ($filename) = @_;
	local $/;
	open my $fh, $filename or die "Couldn't open file $filename: $!";
	my $content = <$fh>;
	return $content;
}

sub write_file {
	my ($filename, $content) = @_;
	open my $fh, '>', $filename or die "Couldn't open file $filename: $!";
	print $fh $content;
}
