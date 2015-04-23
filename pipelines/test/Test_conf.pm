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

package Test_conf;

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
    debug                   => 0,
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
  my @analyses;
  push @analyses, (
    {
      -logic_name => 'init_test',
      -module     => 'InitTest',
      -input_ids  => [{},],
      -hive_capacity => 1,
      -flow_into  => {
        '3' => ['second_computation'],
        '2' => ['first_computation'],
        '1' => ['first_task'],
      },
    },
    {
      -logic_name => 'first_computation',
      -module => 'FirstComputation',
      -hive_capacity => 5,
    },
    {
      -logic_name => 'second_computation',
      -module => 'SecondComputation',
      -hive_capacity => 5,
      -wait_for => ['first_computation'],
    },
    {
      -logic_name => 'first_task',
      -module => 'FirstTask',
      -wait_for => ['second_computation'],
      -flow_into => {
        '2' => ['third_computation'],
        '1' => ['second_task'],
      }
    },
    {
      -logic_name => 'third_computation',
      -module => 'ThirdComputation',
      -hive_capacity => 5,
    },
    {
      -logic_name => 'second_task',
      -module => 'SecondTask',
      -wait_for => ['third_computation'],
      -flow_into => ['finish'],
    },
    {
      -logic_name => 'finish',
      -module => 'Finish',
    }
  );

  return \@analyses;
}

1;
