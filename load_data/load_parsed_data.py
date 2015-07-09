from os import listdir, system
from sys import argv

def create_tables():
  cmd = '''
  set schema 'jt'
  ;

  \set table seamless_login 
  drop table if exists :table
  ;
  create table :table
  ( timestamp timestamp,
    deviceid uuid,
    deviceos text,
    mmminfo text,
    applicationid uuid,
    globaluserid uuid,
    apptypeid int
  )
  ;

  '''
  instance_file = '/home/jteruya/seamless_login/load_data/create_tables_instance.sql'
  with open(instance_file, 'w') as f:
    f.write(cmd)
  system('cat ' + instance_file + ' | psql -h 10.208.97.116 -p 5432 -U analytics etl')

def load_csv(beacon_data_type, csv_file_name):
  cmd = '''
  set schema 'jt'
  ;
  
  \copy ''' + beacon_data_type + ''' from \'''' + csv_file_name + '''\' delimiter ',' csv;
  '''
  instance_file = '/home/jteruya/seamless_login/load_data/load_csv_instance.sql'
  with open(instance_file, 'w') as f:
    f.write(cmd)
  system('cat ' + instance_file + ' | psql -h 10.208.97.116 -p 5432 -U analytics etl')

def main():

  create_tables()

  parsed_data_dir = '/home/jteruya/seamless_login/parse_data/parsed_data/'
  for csv in listdir(parsed_data_dir):
    if 'seamless_login' in csv:
      load_csv('seamless_login', parsed_data_dir + csv)
    else:
      'WTF is goin\' on here?'

if __name__ == '__main__':
  main()
