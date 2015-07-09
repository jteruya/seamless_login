from datetime import date, datetime, timedelta # To generate dates and logstash list
from json import loads
from os import listdir, system
from sys import argv
from time import sleep

def timestamp_message(message):
  print str(datetime.now()).split('.')[0] + ' ' + message + '\n'

def csv_to_list(file_name):
  with open(file_name) as f:
    return [[column.strip() for column in row.split(',')] for row in f.readlines()][1:]

def string_replace(parameter_list,argument_list,template_name,instance_name):
  replace = []

  for i in range(len(parameter_list)):
    replace.append(".replace('" + str(parameter_list[i]) + "','" + str(argument_list[i]) + "')")

  template = open(template_name)
  instance = open(instance_name,'w')

  for line in template:
    cmd = 'instance.write(line' + ''.join(replace) + ')'
    exec cmd

  instance.write('\n')

  template.close()
  instance.close()

def date_to_epoch_range(date_string):
  year = int(date_string.split('-')[0])
  month = int(date_string.split('-')[1])
  day = int(date_string.split('-')[2])

  return [
    int((datetime(year, month, day, 0, 0) - datetime(1970,1,1)).total_seconds() * 1000),
    int((datetime(year, month, day, 23, 59, 59) - datetime(1970,1,1)).total_seconds() * 1000)
  ]

def create_dates_list(start_date, end_date, day_interval):
  start_date = date(
    int(start_date.split('-')[0]),  # Year
    int(start_date.split('-')[1]),  # Month
    int(start_date.split('-')[2])   # Day
  )
  end_date = date(
    int(end_date.split('-')[0]),    # Year
    int(end_date.split('-')[1]),    # Month
    int(end_date.split('-')[2])     # Day
  )
  day_interval = timedelta(days = day_interval)
  current_date = start_date
  if start_date == end_date:
    return [str(current_date)]
  else:
    dates_list = []
    while current_date <= end_date:
      dates_list.append(str(current_date))
      current_date += day_interval
    return dates_list

def create_logstash_string(date_string):
  return 'logstash-'+date_string.replace('-','.')

def create_logstash_list(dates_list):
  return ['logstash-'+date.replace('-','.') for date in dates_list]

def get_size(file_name):
  with open(file_name) as f:
    return loads(f.read())['hits']['total']  

def read_logs(file_name):
  with open(file_name) as f:
    return [l['_source'] for l in loads(f.read())['hits']['hits']]

def main():

  wd = '/home/jteruya/seamless_login/'
  
  metrictypeids = [6] 
  es_data_dir = wd + 'es_data/'

  # applicationid = '6f25c012-bc18-4895-ad9f-dd9669d50341'
  # startdate = '2015-03-31'
  # enddate = '2015-04-02'

  #applicationid = argv[1]
  startdate = argv[1]
  enddate = argv[2]

  dates = create_dates_list(startdate, enddate, 1)
  logstashes = create_logstash_list(dates)

  timestamp_message('List of logstashes to be pulled:')
  print logstashes

  for metrictypeid in metrictypeids:
    for date in dates:
      data_file = es_data_dir+'metrictypeid_'+str(metrictypeid)+'_'+create_logstash_string(date)+'.json'
      # IF LOGIC ADDED FOR DEBUGGING
      # if data_file == es_data_dir+'applicationid_78936830-55C4-4028-8F23-545207AB1800_metrictypeid_8_logstash-2015.04.13.json':
      parameters = [
        '{{ logstash }}',
        '{{ epoch_start }}',
        '{{ epoch_end }}',
        #'{{ applicationid }}',
        '{{ metrictypeid }}',
        '{{ data_file }}',
        '{{ log_size }}'
      ]
      arguments = [
        create_logstash_string(date),
        date_to_epoch_range(date)[0],
        date_to_epoch_range(date)[1],
        #applicationid,
        metrictypeid,
        data_file,
        10
      ]
      es_call_template = wd + 'es_call_templates/get_beacon_data.txt'
      es_call_instance = wd + 'es_call_templates/get_beacon_data.sh'
      string_replace(parameters, arguments, es_call_template, es_call_instance)
      timestamp_message('Generating ' + data_file)
      print 'Parameters:'
      print parameters
      print 'Arguments:'
      print arguments
      system('sh ' + es_call_instance)

      arguments[-1] = get_size(data_file)
      string_replace(parameters, arguments, es_call_template, es_call_instance)
      system('sh ' + es_call_instance)

      sleep(1)

if __name__ == '__main__':
  main()
