=head1 LICENSE

Copyright [1999-2015] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
Copyright [2016-2018] EMBL-European Bioinformatics Institute

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut


=head1 CONTACT

 Please email comments or questions to the public Ensembl
 developers list at <http://lists.ensembl.org/mailman/listinfo/dev>.

 Questions may also be sent to the Ensembl help desk at
 <http://www.ensembl.org/Help/Contact>.

=cut
package RemappingVCF_conf;

use strict;
use warnings;

use Bio::EnsEMBL::Hive::PipeConfig::HiveGeneric_conf;
 # All Hive databases configuration files should inherit from HiveGeneric, directly or indirectly
use base ('Bio::EnsEMBL::Hive::PipeConfig::EnsemblGeneric_conf');

sub default_options {
    my ($self) = @_;
    return {
        %{ $self->SUPER::default_options()
        },    # inherit other stuff from the base class

        hive_auto_rebalance_semaphores => 1,
        hive_force_init                => 1,
        hive_use_param_stack           => 1,
        population => $self->o('population'),
        
        pipeline_dir  => '/hps/nobackup/production/ensembl/anja/release_92/goat/' . $self->o('population') . '/',
        registry_file => '/hps/nobackup/production/ensembl/anja/release_92/goat/variation_qc/ensembl.registry',
        species       => 'goat',
        vcf_file      => $self->o('pipeline_dir') .  $self->o('population') . '.genus_snps.CHIR1_0.20140928.vcf.gz',
        chroms_list   => $self->o('pipeline_dir') .  $self->o('population') . '_chroms_list',
        pipeline_name => 'remap_VCF_' . $self->o('population'),

        hive_db_host    => 'mysql-ens-var-prod-1',
        hive_db_port    => 4449,
        hive_db_user    => 'ensadmin',
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

sub pipeline_wide_parameters {
    my ($self) = @_;
    return {
        %{$self->SUPER::pipeline_wide_parameters}, # here we inherit anything from the base class
        pipeline_dir  => $self->o('pipeline_dir'),
        registry_file => $self->o('registry_file'),
        species       => $self->o('species'),
        vcf_file      => $self->o('vcf_file'),
        chroms_list   => $self->o('chroms_list'),
        population    => $self->o('population'),
    };
}

sub resource_classes {
    my ($self) = @_;
    return {
        %{$self->SUPER::resource_classes},
        'default' => { 'LSF' => '-q production-rh7 -R"select[mem>5500] rusage[mem=5500]" -M5500'},
    };
}

sub pipeline_analyses {
  my ($self) = @_;
  my @analyses;
  push @analyses, (
      {
         -logic_name => 'init_remapping',
         -module     => 'InitRemapping',
         -input_ids  => [{}],
         -rc_name    => 'default',
         -flow_into  => {
          '2->A' => ['remapping'],
          'A->1' => ['join_remapping'],
        },
      },
      {   -logic_name => 'remapping',
          -module     => 'Remapping',
          -rc_name    => 'default',
          -hive_capacity  => 14,
          -max_retry_count => 0,
      },
      {   -logic_name => 'join_remapping',
          -module     => 'JoinRemapping',
          -rc_name    => 'default',
      },
  );
  return \@analyses;
}
1;
