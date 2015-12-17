package MemTest_conf;

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
    '100MB' => { 'LSF' => '-R"select[mem>100] rusage[mem=100]" -M100' },
    '500MB' => { 'LSF' => '-R"select[mem>500] rusage[mem=500]" -M500' },
    '1GB'   => { 'LSF' => '-R"select[mem>1000] rusage[mem=1000]" -M1000' },

  };
}

sub pipeline_wide_parameters {
    my ($self) = @_;
    return {
      %{$self->SUPER::pipeline_wide_parameters},
    };
}

sub pipeline_analyses {
  my ($self) = @_;
  my @analyses = ();
  push @analyses, (
    {
      -logic_name => 'mem_test',
      -module => 'MemTest',
      -input_ids  => [{},],
      -rc_name => '100MB',
      -flow_into => {
        '2->A' => ['computation'],
        'A->1' => ['report_results'],
      }
    }, 
    {
      -logic_name => 'computation',
      -module => 'Computation',
      -rc_name => 'default',
      -flow_into => {
        '-1' => ['computation_highmem']
      },
    },
    {
      -logic_name => 'computation_highmem',
      -module => 'Computation',
      -rc_name => '1GB',
    },
    {
      -logic_name => 'report_results',
      -module => 'ReportResults',
      -rc_name => 'default',
    }
  );
  return \@analyses;
}

1;
