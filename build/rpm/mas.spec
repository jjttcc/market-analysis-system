# Initial spec file created by autospec ver. 0.4 with rpm 2.4.12 compatibility
%define version 1.5
%define rootdir /opt/mas
BuildRoot: /tmp/mas_v%{version}-root
Prefix: %{rootdir}
Summary: Technical analysis and stock charting package
Name: mas
Version: %{version}
Release: 1
Group: Applications/Financial
Copyright: Eiffel Forum License
Source: mas-%{version}.tar.gz
# Following are optional fields
#URL: http://www.example.net/mas_v/
#Distribution: Red Hat Contrib-Net
#Patch: mas_v%{version}.patch
#BuildArchitectures: noarch
#Requires: 
#Obsoletes: 

%description
The Market Analysis System (MAS) is a software application that provides
tools for analysis of financial markets using technical analysis. MAS
provides facilities for stock charting, including price, volume, and a
wide range of technical analysis indicators. MAS also allows automated
processing of market data - applying technical analysis indicators with
user-selected criteria to market data to automatically generate trading
signals - and can be used as the main component of a sophisticated
trading system. Some of the features of MAS are:

   - Exponential Moving Average, Stochastic, MACD, RSI, On Balance Volume,
     Momentum, Rate of Change, etc. 
   - User can create new technical analysis indicators. 
   - User can configure simple and complex criteria for automated signal
     generation.
   - Creation of weekly, monthly, quarterly, and yearly data from daily data. 
   - Handles intraday data. 
   - Can be configured and run as a server that provides services for
     several clients at a time running on remote machines.

%prep
%setup
#%patch

%build
#CFLAGS="$RPM_OPT_FLAGS" ./configure --prefix=/usr

%install
./install --rootdir $RPM_BUILD_ROOT/%{rootdir}

%files
%{rootdir}/bin/macl
%{rootdir}/bin/maclj
%{rootdir}/bin/magc
%{rootdir}/bin/mas
%{rootdir}/bin/mas_assert
%{rootdir}/bin/masb
%{rootdir}/lib/classes
%{rootdir}/lib/config
%{rootdir}/lib/data
%{rootdir}/lib/database
%{rootdir}/lib/libodbc.so.1
%{rootdir}/lib/python
%{rootdir}/lib/stock_splits
%{rootdir}/lib/indicators_persist
%{rootdir}/lib/generators_persist
%{rootdir}/doc
