require 'socket'
require 'timeout'

class IRCConnection

  Message = Struct.new(:prefix, :command, :rawcommand, :params, :rawparams, :rawline)

  DebugLevel = Struct.new(:events, :network)
  class << self
    attr_accessor :debuglevel
  end

  def debuglevel 
    IRCConnection.debuglevel
  end
  
  def debuglevel=(newlevel)
    IRCConnection.debuglevel = newlevel
  end
  
  self.debuglevel = DebugLevel.new(false, false)
  module ReplyCodes #{{{
    RFC2812 = {
      'RPL_WELCOME' => '001',
      'RPL_YOURHOST' => '002',
      'RPL_CREATED' => '003',
      'RPL_MYINFO' => '004',
      'RPL_BOUNCE' => '005',
      'RPL_TRACELINK' => '200',
      'RPL_TRACECONNECTING' => '201',
      'RPL_TRACEHANDSHAKE' => '202',
      'RPL_TRACEUNKNOWN' => '203',
      'RPL_TRACEOPERATOR' => '204',
      'RPL_TRACEUSER' => '205',
      'RPL_TRACESERVER' => '206',
      'RPL_TRACESERVICE' => '207',
      'RPL_TRACENEWTYPE' => '208',
      'RPL_TRACECLASS' => '209',
      'RPL_TRACERECONNECT' => '210',
      'RPL_STATSLINKINFO' => '211',
      'RPL_STATSCOMMANDS' => '212',
      'RPL_STATSCLINE' => '213',
      'RPL_STATSILINE' => '215',
      'RPL_STATSQLINE' => '217',
      'RPL_ENDOFSTATS' => '219',
      'RPL_UMODEIS' => '221',
      'RPL_SERVICEINFO' => '231',
      'RPL_SERVICE' => '233',
      'RPL_SERVLIST' => '234',
      'RPL_SERVLISTEND' => '235',
      'RPL_STATSVLINE' => '240',
      'RPL_STATSUPTIME' => '242',
      'RPL_STATSOLINE' => '243',
      'RPL_STATSHLINE' => '244',
      'RPL_STATSPING' => '246',
      'RPL_STATSDLINE' => '250',
      'RPL_LUSERCLIENT' => '251',
      'RPL_LUSEROP' => '252',
      'RPL_LUSERUNKNOWN' => '253',
      'RPL_LUSERCHANNELS' => '254',
      'RPL_LUSERME' => '255',
      'RPL_ADMINME' => '256',
      'RPL_ADMINLOC1' => '257',
      'RPL_ADMINLOC2' => '258',
      'RPL_ADMINEMAIL' => '259',
      'RPL_TRACE$stderr' => '261',
      'RPL_TRACEEND' => '262',
      'RPL_TRYAGAIN' => '263',
      'RPL_NONE' => '300',
      'RPL_AWAY' => '301',
      'RPL_USERHOST' => '302',
      'RPL_ISON' => '303',
      'RPL_UNAWAY' => '305',
      'RPL_NOWAWAY' => '306',
      'RPL_WHOISUSER' => '311',
      'RPL_WHOISSERVER' => '312',
      'RPL_WHOISOPERATOR' => '313',
      'RPL_WHOWASUSER' => '314',
      'RPL_ENDOFWHO' => '315',
      'RPL_WHOISIDLE' => '317',
      'RPL_ENDOFWHOIS' => '318',
      'RPL_WHOISCHANNELS' => '319',
      'RPL_LISTSTART' => '321',
      'RPL_LIST' => '322',
      'RPL_LISTEND' => '323',
      'RPL_CHANNELMODEIS' => '324',
      'RPL_UNIQOPIS' => '325',
      'RPL_NOTOPIC' => '331',
      'RPL_TOPIC' => '332',
      'RPL_INVITING' => '341',
      'RPL_SUMMONING' => '342',
      'RPL_INVITELIST' => '346',
      'RPL_ENDOFINVITELIST' => '347',
      'RPL_EXCEPTLIST' => '348',
      'RPL_ENDOFEXCEPTLIST' => '349',
      'RPL_VERSION' => '351',
      'RPL_WHOREPLY' => '352',
      'RPL_NAMREPLY' => '353',
      'RPL_KILLDONE' => '361',
      'RPL_CLOSEEND' => '363',
      'RPL_LINKS' => '364',
      'RPL_ENDOFLINKS' => '365',
      'RPL_ENDOFNAMES' => '366',
      'RPL_BANLIST' => '367',
      'RPL_ENDOFBANLIST' => '368',
      'RPL_ENDOFWHOWAS' => '369',
      'RPL_INFO' => '371',
      'RPL_MOTD' => '372',
      'RPL_ENDOFINFO' => '374',
      'RPL_MOTDSTART' => '375',
      'RPL_ENDOFMOTD' => '376',
      'RPL_YOUREOPER' => '381',
      'RPL_REHASHING' => '382',
      'RPL_YOURESERVICE' => '383',
      'RPL_MYPORTIS' => '384',
      'RPL_TIME' => '391',
      'RPL_USERSSTART' => '392',
      'RPL_USERS' => '393',
      'RPL_ENDOFUSERS' => '394',
      'RPL_NOUSERS' => '395',
      'ERR_NOSUCHNICK' => '401',
      'ERR_NOSUCHSERVER' => '402',
      'ERR_NOSUCHCHANNEL' => '403',
      'ERR_CANNOTSENDTOCHAN' => '404',
      'ERR_TOOMANYCHANNELS' => '405',
      'ERR_WASNOSUCHNICK' => '406',
      'ERR_TOOMANYTARGETS' => '407',
      'ERR_NOSUCHSERVICE' => '408',
      'ERR_NOORIGIN' => '409',
      'ERR_NORECIPIENT' => '411',
      'ERR_NOTEXTTOSEND' => '412',
      'ERR_NOTOPLEVEL' => '413',
      'ERR_WILDTOPLEVEL' => '414',
      'ERR_BADMASK' => '415',
      'ERR_UNKNOWNCOMMAND' => '421',
      'ERR_NOMOTD' => '422',
      'ERR_NOADMININFO' => '423',
      'ERR_FILEERROR' => '424',
      'ERR_NONICKNAMEGIVEN' => '431',
      'ERR_ERRONEUSNICKNAME' => '432',
      'ERR_NICKNAMEINUSE' => '433',
      'ERR_NICKCOLLISION' => '436',
      'ERR_UNAVAILRESOURCE' => '437',
      'ERR_USERNOTINCHANNEL' => '441',
      'ERR_NOTONCHANNEL' => '442',
      'ERR_USERONCHANNEL' => '443',
      'ERR_NO$stderrIN' => '444',
      'ERR_SUMMONDISABLED' => '445',
      'ERR_USERSDISABLED' => '446',
      'ERR_NOTREGISTERED' => '451',
      'ERR_NEEDMOREPARAMS' => '461',
      'ERR_ALREADYREGISTRED' => '462',
      'ERR_NOPERMFORHOST' => '463',
      'ERR_PASSWDMISMATCH' => '464',
      'ERR_YOUREBANNEDCREEP' => '465',
      'ERR_YOUWILLBEBANNED' => '466',
      'ERR_KEYSET' => '467',
      'ERR_CHANNELISFULL' => '471',
      'ERR_UNKNOWNMODE' => '472',
      'ERR_INVITEONLYCHAN' => '473',
      'ERR_BANNEDFROMCHAN' => '474',
      'ERR_BADCHANNELKEY' => '475',
      'ERR_BADCHANMASK' => '476',
      'ERR_NOCHANMODES' => '477',
      'ERR_BANLISTFULL' => '478',
      'ERR_NOPRIVILEGES' => '481',
      'ERR_CHANOPRIVSNEEDED' => '482',
      'ERR_CANTKILLSERVER' => '483',
      'ERR_RESTRICTED' => '484',
      'ERR_UNIQOPPRIVSNEEDED' => '485',
      'ERR_NOOPERHOST' => '491',
      'ERR_NOSERVICEHOST' => '492',
      'ERR_UMODEUNKNOWNFLAG' => '501',
      'ERR_USERSDONTMATCH' => '502',
    }
    Aircd = {
      'RPL_ATTEMPTINGJUNC' => '050',
      'RPL_ATTEMPTINGREROUTE' => '051',
      'RPL_STATS' => '210',
      'RPL_LOCALUSERS' => '265',
      'RPL_GLOBALUSERS' => '266',
      'RPL_START_NETSTAT' => '267',
      'RPL_NETSTAT' => '268',
      'RPL_END_NETSTAT' => '269',
      'RPL_NOTIFY' => '273',
      'RPL_ENDNOTIFY' => '274',
      'RPL_CHANINFO_HANDLE' => '285',
      'RPL_CHANINFO_USERS' => '286',
      'RPL_CHANINFO_CHOPS' => '287',
      'RPL_CHANINFO_VOICES' => '288',
      'RPL_CHANINFO_AWAY' => '289',
      'RPL_CHANINFO_OPERS' => '290',
      'RPL_CHANINFO_BANNED' => '291',
      'RPL_CHANINFO_BANS' => '292',
      'RPL_CHANINFO_INVITE' => '293',
      'RPL_CHANINFO_INVITES' => '294',
      'RPL_CHANINFO_KICK' => '295',
      'RPL_CHANINFO_KICKS' => '296',
      'RPL_END_CHANINFO' => '299',
      'RPL_NOTIFYACTION' => '308',
      'RPL_NICKTRACE' => '309',
      'RPL_KICKEXPIRED' => '377',
      'RPL_BANEXPIRED' => '378',
      'RPL_KICKLINKED' => '379',
      'RPL_BANLINKED' => '380',
      'ERR_LENGTHTRUNCATED' => '419',
      'ERR_KICKEDFROMCHAN' => '470',
    }

    Unreal = {
      'RPL_MAP' => '006',
      'RPL_MAPEND' => '007',
      'RPL_STATSBLINE' => '220',
      'RPL_SQLINE_NICK' => '222',
      'RPL_STATSGLINE' => '223',
      'RPL_STATSTLINE' => '224',
      'RPL_STATSELINE' => '225',
      'RPL_STATSNLINE' => '226',
      'RPL_STATSVLINE' => '227',
      'RPL_RULES' => '232',
      'RPL_STATSXLINE' => '247',
      'RPL_STATSCONN' => '250',
      'RPL_HELPHDR' => '290',
      'RPL_HELPOP' => '291',
      'RPL_HELPTLR' => '292',
      'RPL_HELPHLP' => '293',
      'RPL_HELPFWD' => '294',
      'RPL_HELPIGN' => '295',
      'RPL_WHOISREGNICK' => '307',
      'RPL_RULESSTART' => '308',
      'RPL_ENDOFRULES' => '309',
      'RPL_WHOISHELPOP' => '310',
      'RPL_WHOISSPECIAL' => '320',
      'RPL_LISTSYNTAX' => '334',
      'RPL_WHOISBOT' => '335',
      'RPL_WHOISHOST' => '378',
      'RPL_WHOISMODES' => '379',
      'RPL_NOTOPERANYMORE' => '385',
      'RPL_QLIST' => '386',
      'RPL_ENDOFQLIST' => '387',
      'RPL_ALIST' => '388',
      'RPL_ENDOFALIST' => '389',
      'ERR_NOOPERMOTD' => '425',
      'ERR_NORULES' => '434',
      'ERR_SERVICECONFUSED' => '435',
      'ERR_SERVICESDOWN' => '440',
      'ERR_NONICKCHANGE' => '447',
      'ERR_HOSTILENAME' => '455',
      'ERR_NOHIDING' => '459',
      'ERR_NOTFORHALFOPS' => '460',
      'ERR_ONLYSERVERSCANCHANGE' => '468',
      'ERR_LINKSET' => '469',
      'ERR_LINKCHANNEL' => '470',
      'ERR_NEEDREGGEDNICK' => '477',
      'ERR_LINKFAIL' => '479',
      'ERR_CANNOTKNOCK' => '480',
      'ERR_ATTACKDENY' => '484',
      'ERR_KILLDENY' => '485',
      'ERR_HTMDISABLED' => '486',
      'ERR_SECUREONLYCHAN' => '489',
      'ERR_CHANOWNPRIVNEEDED' => '499',
      'ERR_NOINVITE' => '518',
      'ERR_ADMONLY' => '519',
      'ERR_OPERONLY' => '520',
      'ERR_OPERSPVERIFY' => '524',
      'RPL_$stderrON' => '600',
      'RPL_$stderrOFF' => '601',
      'RPL_WATCHOFF' => '602',
      'RPL_WATCHSTAT' => '603',
      'RPL_NOWON' => '604',
      'RPL_NOWOFF' => '605',
      'RPL_WATCHLIST' => '606',
      'RPL_ENDOFWATCHLIST' => '607',
      'RPL_MAPMORE' => '610',
      'RPL_DUMPING' => '640',
      'RPL_DUMPRPL' => '641',
      'RPL_EODUMP' => '642',
      'ERR_CANNOTDOCOMMAND' => '972',
    }

    IRCnet = {
      'RPL_YOURID' => '042',
      'RPL_SAVENICK' => '043',
      'RPL_STATSIAUTH' => '239',
      'RPL_STATSSLINE' => '245',
      'RPL_STATSDEFINE' => '248',
      'RPL_STATSDELTA' => '274',
      'ERR_TOOMANYMATCHES' => '416',
      'ERR_DEAD' => '438',
      'ERR_CHANTOORECENT' => '487',
      'ERR_TSLESSCHAN' => '488',
    }

    Anothernet = {
      'RPL_WHOIS_HIDDEN' => '320',
    }

    Ircu = {
      'RPL_SNOMASK' => '008',
      'RPL_STATMEMTOT' => '009',
      'RPL_STATMEM' => '010',
      'RPL_MAP' => '015',
      'RPL_MAPMORE' => '016',
      'RPL_MAPEND' => '017',
      'RPL_STATSPLINE' => '217',
      'RPL_STATSQLINE' => '228',
      'RPL_STATSVERBOSE' => '236',
      'RPL_STATSENGINE' => '237',
      'RPL_STATSFLINE' => '238',
      'RPL_STATSTLINE' => '246',
      'RPL_STATSGLINE' => '247',
      'RPL_STATSULINE' => '248',
      'RPL_STATSCONN' => '250',
      'RPL_PRIVS' => '270',
      'RPL_SILELIST' => '271',
      'RPL_ENDOFSILELIST' => '272',
      'RPL_STATSDLINE' => '275',
      'RPL_GLIST' => '280',
      'RPL_ENDOFGLIST' => '281',
      'RPL_JUPELIST' => '282',
      'RPL_ENDOFJUPELIST' => '283',
      'RPL_FEATURE' => '284',
      'RPL_WHOISACCOUNT' => '330',
      'RPL_TOPICWHOTIME' => '333',
      'RPL_LISTUSAGE' => '334',
      'RPL_WHOISACTUALLY' => '338',
      'RPL_USERIP' => '340',
      'RPL_WHOSPCRPL' => '354',
      'RPL_TIME' => '391',
      'ERR_QUERYTOOLONG' => '416',
      'ERR_BANNICKCHANGE' => '437',
      'ERR_NICKTOOFAST' => '438',
      'ERR_TARGETTOOFAST' => '439',
      'ERR_INVALIDUSERNAME' => '468',
      'ERR_NEEDREGGEDNICK' => '477',
      'ERR_NOFEATURE' => '493',
      'ERR_BADFEATURE' => '494',
      'ERR_BAD$stderrTYPE' => '495',
      'ERR_BAD$stderrSYS' => '496',
      'ERR_BAD$stderrVALUE' => '497',
      'ERR_ISOPERLCHAN' => '498',
      'ERR_SILELISTFULL' => '511',
      'ERR_BADPING' => '513',
      'ERR_INVALID_ERROR' => '514',
      'ERR_BADEXPIRE' => '515',
      'ERR_DONTCHEAT' => '516',
      'ERR_DISABLED' => '517',
      'ERR_LONGMASK' => '518',
      'ERR_TOOMANYUSERS' => '519',
      'ERR_MASKTOOWIDE' => '520',
      'ERR_QUARANTINED' => '524',
    }

    RatBox = {
      'RPL_MODLIST' => '702',
      'RPL_ENDOFMODLIST' => '703',
      'RPL_HELPSTART' => '704',
      'RPL_HELPTXT' => '705',
      'RPL_ENDOFHELP' => '706',
      'RPL_ETRACEFULL' => '708',
      'RPL_ETRACE' => '709',
      'RPL_KNOCK' => '710',
      'RPL_KNOCKDLVR' => '711',
      'ERR_TOOMANYKNOCK' => '712',
      'ERR_CHANOPEN' => '713',
      'ERR_KNOCKONCHAN' => '714',
      'ERR_KNOCKDISABLED' => '715',
      'RPL_TARGUMODEG' => '716',
      'RPL_TARGNOTIFY' => '717',
      'RPL_UMODEGMSG' => '718',
      'RPL_OMOTDSTART' => '720',
      'RPL_OMOTD' => '721',
      'RPL_ENDOFOMOTD' => '722',
      'ERR_NOPRIVS' => '723',
      'RPL_TESTMARK' => '724',
      'RPL_TESTLINE' => '725',
      'RPL_NOTESTLINE' => '726',
    }

    Ultimate = {
      'RPL_STATSDLINE' => '275',
      'RPL_IRCOPS' => '386',
      'RPL_ENDOFIRCOPS' => '387',
      'ERR_NORULES' => '434',
      'RPL_WATCHCLEAR' => '608',
      'RPL_ISOPER' => '610',
      'RPL_ISLOCOP' => '611',
      'RPL_ISNOTOPER' => '612',
      'RPL_ENDOFISOPER' => '613',
      'RPL_WHOISMODES' => '615',
      'RPL_WHOISHOST' => '616',
      'RPL_WHOISBOT' => '617',
      'RPL_WHOWASHOST' => '619',
      'RPL_RULESSTART' => '620',
      'RPL_RULES' => '621',
      'RPL_ENDOFRULES' => '622',
      'RPL_MAPMORE' => '623',
      'RPL_OMOTDSTART' => '624',
      'RPL_OMOTD' => '625',
      'RPL_ENDOFO' => '626',
      'RPL_SETTINGS' => '630',
      'RPL_ENDOFSETTINGS' => '631',
    }

    AustHex = {
      'RPL_STATSXLINE' => '240',
      'RPL_SUSERHOST' => '307',
      'RPL_WHOISHELPER' => '309',
      'RPL_WHOISSERVICE' => '310',
      'RPL_WHOISVIRT' => '320',
      'RPL_CHANNEL_URL' => '328',
      'RPL_MAP' => '357',
      'RPL_MAPMORE' => '358',
      'RPL_MAPEND' => '359',
      'RPL_SPAM' => '377',
      'RPL_MOTD' => '378',
      'RPL_YOURHELPER' => '380',
      'RPL_NOTOPERANYMORE' => '385',
      'ERR_EVENTNICKCHANGE' => '430',
      'ERR_SERVICENAMEINUSE' => '434',
      'ERR_NOULINE' => '480',
      'ERR_VWORLDWARN' => '503',
      'ERR_WHOTRUNC' => '520',
    }

    Hybrid = {
      'RPL_YOURCOOKIE' => '014',
      'RPL_STATSPLINE' => '220',
      'RPL_STATSFLINE' => '224',
      'RPL_STATSDLINE' => '225',
      'RPL_STATSSLINE' => '245',
      'RPL_STATSULINE' => '246',
      'RPL_STATSXLINE' => '247',
      'RPL_STATSDEBUG' => '249',
      'RPL_LOCALUSERS' => '265',
      'RPL_GLOBALUSERS' => '266',
      'RPL_NOTOPERANYMORE' => '385',
      'ERR_BADCHANNAME' => '479',
      'ERR_DESYNC' => '484',
      'ERR_GHOSTEDCLIENT' => '503',
    }

    BdqIrcd = {
      'RPL_TIME' => '391',
    }

    PTlink = {
      'RPL_STATSXLINE' => '247',
      'ERR_DESYNC' => '484',
      'ERR_CANTKICKADMIN' => '485',
      'RPL_MAPMORE' => '615',
    }

    Ithildin = {
      'RPL_UNKNOWNMODES' => '672',
      'RPL_CANNOTSETMODES' => '673',
      'RPL_XINFO' => '771',
      'RPL_XINFOSTART' => '773',
      'RPL_XINFOEND' => '774',
    }

    Undernet = {
      'RPL_HOSTHIDDEN' => '396',
      'ERR_NOTIMPLEMENTED' => '449',
      'ERR_ISCHANSERVICE' => '484',
      'ERR_VOICENEEDED' => '489',
    }

    Bahamut = {
      'RPL_STATSBLINE' => '220',
      'RPL_STATSBLINE' => '222',
      'RPL_STATSELINE' => '223',
      'RPL_STATSFLINE' => '224',
      'RPL_STATSZLINE' => '225',
      'RPL_STATSCOUNT' => '226',
      'RPL_STATSGLINE' => '227',
      'RPL_STATSSLINE' => '245',
      'RPL_LOCALUSERS' => '265',
      'RPL_GLOBALUSERS' => '266',
      'RPL_WHOISREGNICK' => '307',
      'RPL_WHOISADMIN' => '308',
      'RPL_WHOISSADMIN' => '309',
      'RPL_WHOISSVCMSG' => '310',
      'RPL_CHANNEL_URL' => '328',
      'RPL_CREATIONTIME' => '329',
      'RPL_COMMANDSYNTAX' => '334',
      'RPL_WHOISACTUALLY' => '338',
      'ERR_NOCOLORSONCHAN' => '408',
      'ERR_TOOMANYAWAY' => '429',
      'ERR_BANONCHAN' => '435',
      'ERR_SERVICESDOWN' => '440',
      'ERR_ONLYSERVERSCANCHANGE' => '468',
      'ERR_NEEDREGGEDNICK' => '477',
      'ERR_DESYNC' => '484',
      'ERR_MSGSERVICES' => '487',
      'ERR_TOOMANYWATCH' => '512',
      'ERR_TOOMANYDCC' => '514',
      'ERR_LISTSYNTAX' => '521',
      'ERR_WHOSYNTAX' => '522',
      'ERR_WHOLIMEXCEED' => '523',
      'RPL_$stderrON' => '600',
      'RPL_$stderrOFF' => '601',
      'RPL_WATCHOFF' => '602',
      'RPL_WATCHSTAT' => '603',
      'RPL_NOWON' => '604',
      'RPL_NOWOFF' => '605',
      'RPL_WATCHLIST' => '606',
      'RPL_ENDOFWATCHLIST' => '607',
      'RPL_DCCSTATUS' => '617',
      'RPL_DCCLIST' => '618',
      'RPL_ENDOFDCCLIST' => '619',
      'RPL_DCCINFO' => '620',
      'ERR_NUMERIC_ERR' => '999',
    }

    KineIRCd = {
      'RPL_MYINFO' => '004',
      'RPL_AWAY' => '301',
      'RPL_TRACEROUTE_HOP' => '660',
      'RPL_TRACEROUTE_START' => '661',
      'RPL_MODECHANGEWARN' => '662',
      'RPL_CHANREDIR' => '663',
      'RPL_SERVMODEIS' => '664',
      'RPL_OTHERUMODEIS' => '665',
      'RPL_ENDOF_GENERIC' => '666',
      'RPL_WHOWASDETAILS' => '670',
      'RPL_WHOISSECURE' => '671',
      'RPL_LUSERSTAFF' => '678',
      'RPL_TIMEONSERVERIS' => '679',
      'RPL_NETWORKS' => '682',
      'RPL_YOURLANGUAGEIS' => '687',
      'RPL_LANGUAGE' => '688',
      'RPL_WHOISSTAFF' => '689',
      'RPL_WHOISLANGUAGE' => '690',
      'ERR_CANNOTCHANGEUMODE' => '973',
      'ERR_CANNOTCHANGECHANMODE' => '974',
      'ERR_CANNOTCHANGESERVERMODE' => '975',
      'ERR_CANNOTSENDTONICK' => '976',
      'ERR_UNKNOWNSERVERMODE' => '977',
      'ERR_SERVERMODELOCK' => '979',
      'ERR_BADCHARENCODING' => '980',
      'ERR_TOOMANYLANGUAGES' => '981',
      'ERR_NOLANGUAGE' => '982',
      'ERR_TEXTTOOSHORT' => '983',
    }

    GameSurge = {
      'RPL_INVITED' => '345',
    }

    QuakeNet = {
      'RPL_WELCOME' => '001',
      'RPL_YOURHOST' => '002',
      'RPL_CREATED' => '003',
      'RPL_MYINFO' => '004',
      'RPL_ISUPPORT' => '005',
      'RPL_SNOMASK' => '008',
      'RPL_MAP' => '015',
      'RPL_MAPMORE' => '016',
      'RPL_MAPEND' => '017',
      'RPL_TRACELINK' => '200',
      'RPL_TRACECONNECTING' => '201',
      'RPL_TRACEHANDSHAKE' => '202',
      'RPL_TRACEUNKNOWN' => '203',
      'RPL_TRACEOPERATOR' => '204',
      'RPL_TRACEUSER' => '205',
      'RPL_TRACESERVER' => '206',
      'RPL_TRACENEWTYPE' => '208',
      'RPL_TRACECLASS' => '209',
      'RPL_STATSLINKINFO' => '211',
      'RPL_STATSCOMMANDS' => '212',
      'RPL_STATSCLINE' => '213',
      'RPL_STATSILINE' => '215',
      'RPL_STATSKLINE' => '216',
      'RPL_STATSPLINE' => '217',
      'RPL_STATSYLINE' => '218',
      'RPL_ENDOFSTATS' => '219',
      'RPL_UMODEIS' => '221',
      'RPL_STATSQLINE' => '228',
      'RPL_STATSVERBOSE' => '236',
      'RPL_STATSENGINE' => '237',
      'RPL_STATSFLINE' => '238',
      'RPL_STATSLLINE' => '241',
      'RPL_STATSUPTIME' => '242',
      'RPL_STATSOLINE' => '243',
      'RPL_STATSHLINE' => '244',
      'RPL_STATSTLINE' => '246',
      'RPL_STATSGLINE' => '247',
      'RPL_STATSULINE' => '248',
      'RPL_STATSDEBUG' => '249',
      'RPL_STATSCONN' => '250',
      'RPL_LUSERCLIENT' => '251',
      'RPL_LUSEROP' => '252',
      'RPL_LUSERUNKNOWN' => '253',
      'RPL_LUSERCHANNELS' => '254',
      'RPL_LUSERME' => '255',
      'RPL_ADMINME' => '256',
      'RPL_ADMINLOC' => '257',
      'RPL_ADMINLOC' => '258',
      'RPL_ADMINEMAIL' => '259',
      'RPL_PRIVS' => '270',
      'RPL_SILELIST' => '271',
      'RPL_ENDOFSILELIST' => '272',
      'RPL_STATSDLINE' => '275',
      'RPL_GLIST' => '280',
      'RPL_ENDOFGLIST' => '281',
      'RPL_JUPELIST' => '282',
      'RPL_ENDOFJUPELIST' => '283',
      'RPL_FEATURE' => '284',
      'RPL_CHKHEAD' => '286',
      'RPL_CHANUSER' => '287',
      'RPL_DATASTR' => '290',
      'RPL_ENDOFCHECK' => '291',
      'RPL_AWAY' => '301',
      'RPL_USERHOST' => '302',
      'RPL_ISON' => '303',
      'RPL_TEXT' => '304',
      'RPL_UNAWAY' => '305',
      'RPL_NOWAWAY' => '306',
      'RPL_WHOISUSER' => '311',
      'RPL_WHOISSERVER' => '312',
      'RPL_WHOISOPERATOR' => '313',
      'RPL_WHOWASUSER' => '314',
      'RPL_ENDOFWHO' => '315',
      'RPL_WHOISIDLE' => '317',
      'RPL_ENDOFWHOIS' => '318',
      'RPL_WHOISCHANNELS' => '319',
      'RPL_LISTSTART' => '321',
      'RPL_LIST' => '322',
      'RPL_LISTEND' => '323',
      'RPL_CHANNELMODEIS' => '324',
      'RPL_CREATIONTIME' => '329',
      'RPL_WHOISACCOUNT' => '330',
      'RPL_NOTOPIC' => '331',
      'RPL_TOPIC' => '332',
      'RPL_TOPICWHOTIME' => '333',
      'RPL_LISTUSAGE' => '334',
      'RPL_WHOISACTUALLY' => '338',
      'RPL_USERIP' => '340',
      'RPL_INVITING' => '341',
      'RPL_INVITELIST' => '346',
      'RPL_ENDOFINVITELIST' => '347',
      'RPL_VERSION' => '351',
      'RPL_WHOREPLY' => '352',
      'RPL_NAMREPLY' => '353',
      'RPL_WHOSPCRPL' => '354',
      'RPL_DELNAMREPLY' => '355',
      'RPL_CLOSING' => '362',
      'RPL_CLOSEEND' => '363',
      'RPL_LINKS' => '364',
      'RPL_ENDOFLINKS' => '365',
      'RPL_ENDOFNAMES' => '366',
      'RPL_BANLIST' => '367',
      'RPL_ENDOFBANLIST' => '368',
      'RPL_ENDOFWHOWAS' => '369',
      'RPL_INFO' => '371',
      'RPL_MOTD' => '372',
      'RPL_ENDOFINFO' => '374',
      'RPL_MOTDSTART' => '375',
      'RPL_ENDOFMOTD' => '376',
      'RPL_YOUREOPER' => '381',
      'RPL_REHASHING' => '382',
      'RPL_TIME' => '391',
      'RPL_HOSTHIDDEN' => '396',
      'RPL_STATSSLINE' => '398',
      'ERR_NOSUCHNICK' => '401',
      'ERR_NOSUCHSERVER' => '402',
      'ERR_NOSUCHCHANNEL' => '403',
      'ERR_CANNOTSENDTOCHAN' => '404',
      'ERR_TOOMANYCHANNELS' => '405',
      'ERR_WASNOSUCHNICK' => '406',
      'ERR_SEARCHNOMATCH' => '408',
      'ERR_NOORIGIN' => '409',
      'ERR_NORECIPIENT' => '411',
      'ERR_NOTEXTTOSEND' => '412',
      'ERR_NOTOPLEVEL' => '413',
      'ERR_WILDTOPLEVEL' => '414',
      'ERR_QUERYTOOLONG' => '416',
      'ERR_UNKNOWNCOMMAND' => '421',
      'ERR_NOMOTD' => '422',
      'ERR_NOADMININFO' => '423',
      'ERR_NONICKNAMEGIVEN' => '431',
      'ERR_ERRONEUSNICKNAME' => '432',
      'ERR_NICKNAMEINUSE' => '433',
      'ERR_NICKCOLLISION' => '436',
      'ERR_BANNICKCHANGE' => '437',
      'ERR_NICKTOOFAST' => '438',
      'ERR_TARGETTOOFAST' => '439',
      'ERR_USERNOTINCHANNEL' => '441',
      'ERR_NOTONCHANNEL' => '442',
      'ERR_USERONCHANNEL' => '443',
      'ERR_NOTREGISTERED' => '451',
      'ERR_NEEDMOREPARAMS' => '461',
      'ERR_ALREADYREGISTRED' => '462',
      'ERR_PASSWDMISMATCH' => '464',
      'ERR_YOUREBANNEDCREEP' => '465',
      'ERR_KEYSET' => '467',
      'ERR_INVALIDUSERNAME' => '468',
      'ERR_CHANNELISFULL' => '471',
      'ERR_UNKNOWNMODE' => '472',
      'ERR_INVITEONLYCHAN' => '473',
      'ERR_BANNEDFROMCHAN' => '474',
      'ERR_BADCHANNELKEY' => '475',
      'ERR_NEEDREGGEDNICK' => '477',
      'ERR_BANLISTFULL' => '478',
      'ERR_BADCHANNAME' => '479',
      'ERR_NOPRIVILEGES' => '481',
      'ERR_CHANOPRIVSNEEDED' => '482',
      'ERR_CANTKILLSERVER' => '483',
      'ERR_ISCHANSERVICE' => '484',
      'ERR_ISREALSERVICE' => '485',
      'ERR_ACCOUNTONLY' => '486',
      'ERR_VOICENEEDED' => '489',
      'ERR_NOOPERHOST' => '491',
      'ERR_NOFEATURE' => '493',
      'ERR_BADFEATVALUE' => '494',
      'ERR_BADLOGTYPE' => '495',
      'ERR_BADLOGSYS' => '496',
      'ERR_BADLOGVALUE' => '497',
      'ERR_ISOPERLCHAN' => '498',
      'ERR_UMODEUNKNOWNFLAG' => '501',
      'ERR_USERSDONTMATCH' => '502',
      'ERR_SILELISTFULL' => '511',
      'ERR_NOSUCHGLINE' => '512',
      'ERR_BADPING' => '513',
      'ERR_NOSUCHJUPE' => '514',
      'ERR_BADEXPIRE' => '515',
      'ERR_DONTCHEAT' => '516',
      'ERR_DISABLED' => '517',
      'ERR_LONGMASK' => '518',
      'ERR_TOOMANYUSERS' => '519',
      'ERR_MASKTOOWIDE' => '520',
      'ERR_QUARANTINED' => '524',
      'ERR_BADHOSTMASK' => '530',
      'ERR_HOSTUNAVAIL' => '531',
    }

  end # }}}
  def initialize()
    @events = Hash.new {|h,k| h[k] = {} }
    @codetable_names = ReplyCodes::RFC2812
    @codetable_numerics = @codetable_names.invert
  end

  def add_codes(additionalcodes)
    @codetable_names.merge! additionalcodes
    @codetable_numerics = @codetable_names.invert
  end

  def connect(host, port)
    @conn = TCPsocket.new(host, port)
  end

  def disconnect
    @conn.close
  end

  def call_events(msg)
    command = msg.command
    catch (:event_ignore_other) do 
      n = 1
      @events[command].each do |key,event|
        next if key == :default
        n += call_event(event, key, msg)
      end
      if n == 1 and @events[command].key? :default
        call_event(@events[command][:default], :default, msg)
      end
    end
  end

  def call_event(event, name, msg)
    val = 0
    if debuglevel.events
      $stderr.puts "Entering event #{key} for command #{command}"
      $stderr.flush
    end
    begin
      ret = catch(:event_done) do 
        event.call(msg, self)
      end
      case ret
      when :success
        val = 1
      when :end
        throw :event_ignore_other
      else
        # nothing now
      end
    rescue Exception => e
      #$stderr.puts "Exception occured during processing of event #{key} for command #{command}"
      $stderr.puts e
    ensure
      if debuglevel.events
        # $stderr.puts "Leaving event #{key} for command #{command}"
        $stderr.flush
      end
    end
    return val
  end

  def internal_to_command(str)
    if @codetable_numerics.has_key? str
      return @codetable_numerics[str]
    end 
    return str
  end
  def command_to_internal(str)
    if @codetable_names.has_key? str
      return @codetable_names[str]
    end 
    return str
  end

  def add_event(commands, name, &block)
    commands = [commands] if commands.is_a? String or commands.is_a? Symbol
    commands.map! { |command| command.to_s.upcase }
    commands.each do |command|
      @events[command][name] = block
    end
  end

  def remove_event(commands, name)
    commands = commands.to_s if commands.is_a? Symbol
    commands = [commands] if commands.is_a? String
    commands.each do |command|
      @events[command.upcase].delete name
    end
  end

  def send(*args)
    args.each do |line|
      @conn.write line.chomp + "\r\n"
      if debuglevel.network
        $stderr.puts "-> #{line}"
        $stderr.flush
      end
    end
  end

  def parse_line(line)
    line =~ /^
             (\:(\S+) \x20)? #prefix
             (\d{3}|[a-z]+)  #command
             (\x20(.*))?     #params
             \r$/ix 
    prefix, rawcommand, rawparams = $2, $3, $5
    params = []
    if rawparams =~ /:/
      lpart, rpart = rawparams.split(':', 2)
      params = lpart.split
      params.push rpart
    else
      params = rawparams.split
    end

    command = rawcommand
    if command == "PRIVMSG" and params[i = params.index(":").to_i + 1] == 1
      if params[(i+1),3] == "DCC"
        command = "DCC"
      else
        command = "CTCP"
      end
    end
    command = internal_to_command(command)
    return Message.new(prefix, command, rawcommand, params, rawparams, line)
  end

  def each  
    @conn.each do |line|
      if debuglevel.network
        $stderr.puts "<- #{line}"
        $stderr.flush
      end
      msg = parse_line(line)
      call_events(msg)
      yield(msg, self)
    end
  end

  def process_line
    line = @conn.gets
    if debuglevel.network
      $stderr.puts "<- #{line}"
      $stderr.flush
    end
    msg = parse_line(line)
    call_events(msg)
    yield(msg, self)
  end

  def loop
    each {}
  end

end
