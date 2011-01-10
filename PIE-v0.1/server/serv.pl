#!/usr/bin/perl

#    pie
#    a twitter-like app for airplug
#    authors: Christophe Boudet, Julien Castaigne, Jonathan Roudire,
#             Christophe Roquette, JŽrŽmy Subtil
#    license type: free of charge license for academic and research purpose
#    see license.txt


package MyPackage;
use base qw(Net::Server);
use DBI;
use Digest::HMAC_MD5 qw(hmac_md5 hmac_md5_hex);
use Net::Twitter;
use Scalar::Util 'blessed';


#information de connection la base de donnŽe (server type myqsl, sur localhost avec user pie , password pie et database pie
$dbh = DBI->connect('DBI:mysql:pie;host=localhost', 'pie', 'pie' ) || die "Could not connect to database: $DBI::errstr";


# When no authentication is required:
my $nt = Net::Twitter->new(legacy => 0);

#OAuth for authenticated requests
my $nt = Net::Twitter->new(
      traits   => [qw/OAuth API::REST/],
      consumer_key        => "g1ndSVyu5jmpHnOsfMZQ",
      consumer_secret     => "QXglUVWrr6hSmNf3jqyroIyDvaWbfqQKebbK1UimU",
      access_token        => "234867387-S2wngz01TAx5w5zLn82UCvJBoTcywSXBvLSNu2X3",
      access_token_secret => "Lq4Kk5qZVTuvwQJN0fMlb6S4SdsH7VO6klESpUiGwM",
);


#server
sub process_request {
	my $self = shift;
    while (<STDIN>) {
            s/\r?\n$//;
            
            #extraction des infos
            $_ =~ /^user:([a-z0-9]*?);key:([a-zA-Z0-9]*?);id:([a-zA-Z0-9]*?);msg:(.*)$/;
            $user 	= $1;
            $key 	= $2;
			$id		= $3;
			$msg 	= $4;

			#test secu
			if((length($user) > 1) && (length($key) > 30) && (length($id) > 0) && (length($msg) > 1))
			{
				
				#recup les infos de l'user
				$sth = $dbh->prepare("SELECT id,password FROM user WHERE login='$user'");
				$sth->execute();
				$result = $sth->fetchrow_hashref();
				
				#test de la clef
				$digest = hmac_md5_hex($msg, $result->{password});
				if(lc($key) eq $digest)
				{
					print "=>OK\n";
					
					#insere le msg
					$dbh->do("INSERT INTO message (user, date, id_msg, msg) VALUES('$user', NOW(), '$id', '$msg')");
					$nt->update($msg);
				}
				print "$digest\n"; 

			
			}
			
            last if /quit/i;
    }
}

#port du server
MyPackage->run(port => 8000);
$dbh->disconnect();
