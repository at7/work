=head1 LICENSE

Copyright (c) 1999-2013 The European Bioinformatics Institute and
Genome Research Limited.  All rights reserved.

This software is distributed under a modified Apache license.
For license details, please see

http://www.ensembl.org/info/about/legal/code_licence.html

=head1 CONTACT

Please email comments or questions to the public Ensembl
developers list at <dev@ensembl.org>.

Questions may also be sent to the Ensembl help desk at
<helpdesk@ensembl.org>.

=cut

package DumpVEP_conf;

use strict;
use warnings;

use base ('Bio::EnsEMBL::Hive::PipeConfig::HiveGeneric_conf');
sub default_options {
  my ($self) = @_;

# The hash returned from this function is used to configure the
# pipeline, you can supply any of these options on the command
# line to override these default values.

# You shouldn't need to edit anything in this file other than
# these values, if you find you do need to then we should probably
# make it an option here, contact the variation team to discuss
# this - patches are welcome!
  return {
    hive_force_init         => 1,
    hive_use_param_stack    => 0,
    hive_use_triggers       => 0,
    hive_auto_rebalance_semaphores => 0,  # do not attempt to rebalance semaphores periodically by default
    hive_no_init            => 0, # setting it to 1 will skip pipeline_create_commands (useful for topping up)
    hive_root_dir           => $ENV{'HOME'} . '/DEV/ensembl-hive',
    ensembl_cvs_root_dir    => $ENV{'HOME'} . '/DEV',
    hive_db_port            => 3306,
    hive_db_user            => 'ensadmin',
    hive_db_host            => 'ens-variation',
    pipeline_name           => 'ehive_test',
    pipeline_dir            => $self->o('pipeline_dir'),
    registry_file           => $self->o('pipeline_dir') . '/ensembl.registry',
    debug                   => 1,
    pipeline_db => {
        -host   => $self->o('hive_db_host'),
        -port   => $self->o('hive_db_port'),
        -user   => $self->o('hive_db_user'),
        -pass   => $self->o('hive_db_password'),
        -dbname => $ENV{'USER'} . '_' . $self->o('pipeline_name'),
        -driver => 'mysql',
    },
  };
}

sub resource_classes {
  my ($self) = @_;
  return {
  %{$self->SUPER::resource_classes},
    'default' => { 'LSF' => '-R"select[mem>1500] rusage[mem=1500]" -M1500'}, 
  };
}


sub pipeline_wide_parameters {
    my ($self) = @_;
    return {
      %{$self->SUPER::pipeline_wide_parameters},
      registry_file => $self->o('registry_file'),
      pipeline_dir  => $self->o('pipeline_dir'),
      debug         => $self->o('debug'),
    };
}

sub pipeline_analyses {
  my ($self) = @_;
  my @common_params = map {$_ => $self->o($_) || undef} qw(
    ensembl_release
    ensembl_cvs_root_dir
    pipeline_dir
    debug
  );
  my @analyses;

  push @analyses, (
    {
      -logic_name => 'init_dump_vep',
      -module     => 'InitDump',
      -input_ids  => [{},],
      -hive_capacity => 1,
      -flow_into     => {
        '1' => $self->o('debug') ? [] : ['distribute'],
        '2' => $self->o('debug') ? ['dump_vep'] : ['dump_vep', 'finish_dump'],
        '3' => ['merge_vep'],
        '4' => ['convert_vep'],
      },
    },
    {
      -logic_name    => 'dump_vep',
      -module        => 'DumpVEP',
      -parameters    => {
        @common_params
      },
      -rc_name       => 'default',
      -hive_capacity => 3,
    },
    {
      -logic_name    => 'merge_vep',
      -module        => 'MergeVEP',
      -parameters    => { @common_params },
      -wait_for      => ['dump_vep'],
      -hive_capacity => 10,
    },
    {
      -logic_name    => 'convert_vep',
      -module        => 'ConvertVEP',
      -parameters    => { @common_params },
      -wait_for      => ['merge_vep'],
      -hive_capacity => 10,
    }
  );
  if (!$self->o('debug')) {
    push @analyses, (
      {
        -logic_name => 'finish_dump',
        -module     => 'FinishVEP',
        -parameters => { @common_params },
        -wait_for   => ['convert_vep'],
      },
      {
        -logic_name => 'distribute',
        -module     => 'DistributeDumps',
        -parameters => { @common_params },
        -wait_for   => ['finish_dump'],
      }
    );
  }

  return \@analyses;
}

1;
