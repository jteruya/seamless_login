from csv import writer
from datetime import datetime
from dateutil.parser import parse # to format from iso date to timestamp, to parse input dates
from json import loads
from os import listdir
from pprint import pprint
from sys import argv

#######################################################
# This script parses JSON files created from ES pulls #
#######################################################

def timestamp_message(message):
  print str(datetime.now()).split('.')[0] + ' ' + message + '\n'

def cast_to_timestamp(time_obj):
  return parse(time_obj).strftime('%Y-%m-%d %H:%M:%S')

# Read records from ES written to JSON file
def read_logs(file_name):
  with open(file_name) as f:
     return [l['_source'] for l in loads(f.read())['hits']['hits']]
     # test = [l['_source'] for l in loads(f.read())['hits']['hits']]
     # return 1



# Write detected ES records to CSV
def write_detected(list_name, app_id, metric_id, log_id):
  with open('/home/jteruya/beacon_tools/parse_data/parsed_data/detected_' + app_id + '_' + metric_id + '_' + log_id + '.csv', 'w') as f:
    w = writer(f)
    for l in list_name:
      #######
      # iOS #
      #######
      if l['SessionData']['AppTypeId'] in [1,2]:
        if loads(l['ContextData'])['identifier'] == 'beacons':
          if loads(l['ContextData'])['metadata']['beacons'] != []:
            beacons = loads(l['ContextData'])['metadata']['beacons']
            timestamp = cast_to_timestamp(l['@timestamp'])
            applicationid = l['applicationId']
            globaluserid = l['GlobalUserId']
            binaryversion = l['SessionData']['BinaryVersion']
            apptypeid = l['SessionData']['AppTypeId']

            for b in beacons:
              uuid = b['uuid']
              major = b['major']
              minor = b['minor']

              record = timestamp, applicationid, globaluserid, binaryversion, apptypeid, uuid, major, minor
              w.writerow(record)

      ###########
      # Android #
      ###########
      if l['SessionData']['AppTypeId'] == 3:
        if l['Metadata'] != None:
          if 'beacons' in loads(l['Metadata']).keys():
            if loads(l['Metadata'])['beacons']['Values'] != []:
            #if loads(l['Metadata'])['beacons'] != ['[]']:
              beacons = loads(l['Metadata'])['beacons']['Values']
              #beacons = loads(loads(l['Metadata'])['beacons'][0])
              #beacons = loads(loads(l['Metadata'])['beacons']) 
              timestamp = cast_to_timestamp(l['@timestamp'])
              applicationid = l['applicationId']
              globaluserid = l['GlobalUserId']
              binaryversion = l['SessionData']['BinaryVersion']
              apptypeid = l['SessionData']['AppTypeId']
              for b in beacons:
                 uuid = b['NameValuePairs']['uuid']
                 major = b['NameValuePairs']['major']
                 minor = b['NameValuePairs']['minor']
                 #uuid = b['uuid']
                 #major = b['major']
                 #minor = b['minor']

                 record = timestamp, applicationid, globaluserid, binaryversion, apptypeid, uuid, major, minor
                 w.writerow(record)

# Write notified ES records to CSV
def write_notified(list_name, app_id, metric_id, log_id):
  with open('/home/jteruya/beacon_tools/parse_data/parsed_data/notified_' + app_id + '_' + metric_id + '_' + log_id + '.csv', 'w') as f:
    w = writer(f)
    for l in list_name:
      #######
      # iOS #
      #######
      if l['SessionData']['AppTypeId'] in [1,2]:
        if loads(l['ContextData'])['identifier'] == 'beacon':
          timestamp = cast_to_timestamp(l['@timestamp'])
          applicationid = l['applicationId']
          globaluserid = l['GlobalUserId']
          binaryversion = l['SessionData']['BinaryVersion']
          apptypeid = l['SessionData']['AppTypeId']

          uuid = loads(l['ContextData'])['metadata']['beacon']['uuid']
          major = loads(l['ContextData'])['metadata']['beacon']['major']
          minor = loads(l['ContextData'])['metadata']['beacon']['minor']
          state = loads(l['ContextData'])['metadata']['state']
          msgtype = loads(l['ContextData'])['metadata']['type']
          messageid = loads(l['ContextData'])['metadata']['messageid']

          record = timestamp, applicationid, globaluserid, binaryversion, apptypeid, uuid, major, minor, state, msgtype, messageid
          w.writerow(record)

      ###########
      # Android #
      ###########
      if l['SessionData']['AppTypeId'] == 3:
        if loads(l['Metadata'])['identifier'] == 'notifications':
          timestamp = cast_to_timestamp(l['@timestamp'])
          applicationid = l['applicationId']
          globaluserid = l['GlobalUserId']
          binaryversion = l['SessionData']['BinaryVersion']
          apptypeid = l['SessionData']['AppTypeId']

          uuid = loads(l['Metadata'])['beacon']['NameValuePairs']['uuid']
          major = loads(l['Metadata'])['beacon']['NameValuePairs']['major']
          minor = loads(l['Metadata'])['beacon']['NameValuePairs']['minor']
          state = loads(l['Metadata'])['state']
          msgtype = loads(l['Metadata'])['type']
          messageid = loads(l['Metadata'])['messageid']

          record = timestamp, applicationid, globaluserid, binaryversion, apptypeid, uuid, major, minor, state, msgtype, messageid
          w.writerow(record)

# Write seamlesslogin ES records to CSV
def write_seamlessloginsuccess(list_name, metric_id, log_id):
  with open('/home/jteruya/seamless_login/parse_data/parsed_data/seamless_login_' + metric_id + '_' + log_id + '.csv', 'w') as f:
    w = writer(f)
    for l in list_name:
      timestamp = cast_to_timestamp(l['@timestamp'])
      deviceid = l['SessionData']['DeviceId']
      deviceos = l['SessionData']['DeviceOSVersion']
      mmminfo = l['SessionData']['MMMInfo']
      applicationid = l['ApplicationId']
      globaluserid = l['GlobalUserId']
      apptypeid = l['SessionData']['AppTypeId']
      record = timestamp, deviceid, deviceos, mmminfo, applicationid, globaluserid, apptypeid
      w.writerow(record)

# Write actioned ES records to CSV
def write_actioned(list_name, app_id, metric_id, log_id):
  with open('/home/jteruya/beacon_tools/parse_data/parsed_data/actioned_' + app_id + '_' + metric_id + '_' + log_id + '.csv', 'w') as f:
    w = writer(f)
    for l in list_name:
      if type(l['SessionData']).__name__ != 'NoneType':
      #######
      # iOS #
      #######
        if l['SessionData']['AppTypeId'] in [1,2]:
          if l['UserActionData']['Type'] == 'beaconnotification':
            timestamp = cast_to_timestamp(l['@timestamp'])
            applicationid = l['applicationId']
            globaluserid = l['GlobalUserId']
            binaryversion = l['SessionData']['BinaryVersion']
            apptypeid = l['SessionData']['AppTypeId']

            uuid = loads(l['Metadata'])['beacon']['uuid']
            major = loads(l['Metadata'])['beacon']['major']
            minor = loads(l['Metadata'])['beacon']['minor']

            msgtype = loads(l['Metadata'])['type']
            messageid = loads(l['Metadata'])['messageid']

            record = timestamp, applicationid, globaluserid, binaryversion, apptypeid, uuid, major, minor, msgtype, messageid
            w.writerow(record)

        ###########
        # Android #
        ###########
        if l['SessionData']['AppTypeId'] == 3:
          if l['UserActionData']['Type'] == 'beacon':
            timestamp = cast_to_timestamp(l['@timestamp'])
            applicationid = l['applicationId']
            globaluserid = l['GlobalUserId']
            binaryversion = l['SessionData']['BinaryVersion']
            apptypeid = l['SessionData']['AppTypeId']

            uuid = loads(loads(l['Metadata'])['beacon'])['uuid']
            major = loads(loads(l['Metadata'])['beacon'])['major']
            minor = loads(loads(l['Metadata'])['beacon'])['minor']

            msgtype = loads(l['Metadata'])['type']
            messageid = loads(l['Metadata'])['messageid']

            record = timestamp, applicationid, globaluserid, binaryversion, apptypeid, uuid, major, minor, msgtype, messageid
            w.writerow(record)

def main():

  # Location of JSON files created fom ES pulls
  es_data_dir = '/home/jteruya/seamless_login/es_data/'

  # For each JSON file created in ES pulls
  for es_data_file in listdir(es_data_dir):
    #str_applicationid = es_data_file.split('_')[1]
    str_metrictypeid = es_data_file.split('_')[1]
    str_logstash = es_data_file.split('_')[2].split('.json')[0]
    
    #print str_metrictypeid
    #print str_logstash

    # Checkpoint
    if str_metrictypeid == '6':
      timestamp_message('Begin parsing metric type ' + str_metrictypeid + ' from ' + str_logstash + '...')
      logs = read_logs(es_data_dir + es_data_file)
      timestamp_message('Records to parse: ' + str(len(logs)))
      if len(logs) > 0:
         write_seamlessloginsuccess(logs, str_metrictypeid, str_logstash)
      timestamp_message('Done parsing!')

    # Detected
    if str_metrictypeid == '8':
      timestamp_message('Begin parsing metric type ' + str_metrictypeid + ' data for applicationid ' + str_applicationid + ' from ' + str_logstash + '...')
      logs = read_logs(es_data_dir + es_data_file)
      timestamp_message('Records to parse: ' + str(len(logs)))
      write_detected(logs, str_applicationid, str_metrictypeid, str_logstash)
      timestamp_message('Done parsing!')

    # Notified
    if str_metrictypeid == '9':
      timestamp_message('Begin parsing metric type ' + str_metrictypeid + ' data for applicationid ' + str_applicationid + ' from ' + str_logstash + '...')
      logs = read_logs(es_data_dir + es_data_file)
      timestamp_message('Records to parse: ' + str(len(logs)))
      write_notified(logs, str_applicationid, str_metrictypeid, str_logstash)
      timestamp_message('Done parsing!')

    # Actioned
    if str_metrictypeid == '5':
      timestamp_message('Begin parsing metric type ' + str_metrictypeid + ' data for applicationid ' + str_applicationid + ' from ' + str_logstash + '...')
      logs = read_logs(es_data_dir + es_data_file)
      timestamp_message('Records to parse: ' + str(len(logs)))
      write_actioned(logs, str_applicationid, str_metrictypeid, str_logstash)
      timestamp_message('Done parsing!')

if __name__ == '__main__':
  main()
