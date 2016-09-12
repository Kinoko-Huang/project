      program  greg2jul
c****************************************
c this program reads a command line 
c  arguement of a date in the YYYYMMDDHH format
c  and writes out a YYYYJJJHH julian date
c
c this algorithm was shamelessly lifted
c  from the MM5 RIP processor.
c
c***************************************
      character*10 card  
      character*3  dayofweek(7)
      integer julian
      data dayofweek /'Sun','Mon','Tue','Wed','Thu','Fri','Sat'/

      call getarg(1,card)
      read(card,'(i4,2i2)')iyr,imo,idy
      read(card,'(2x,i6)')md
      call mconvert(100*md,mh,1,1970)
      idow=mod(mh/24+1,7)+1
      write(*,'(a3)')dayofweek(idow)

      end

c
c*******************************************
c
      integer function gdate(year,month,day)
c
c--- gdate -  this function returns the gregorian day for a given
c             date. routine obtained from  hewlett-packard 41c 
c             financial library, appendix.
c
      integer year,month,day,adyear,xmo,zyr
c
      if(year.lt.1900)then
         adyear = year + 1900
      else
         adyear = year
      endif
c
      if(month.lt.3)then
         xmo   = 0
         zyr   = adyear - 1
      else
         xmo   = int( 0.4*float(month) + 2.3 )
         zyr   = adyear
      endif
c
      gdate    = 365*adyear + 31*(month-1) + day + 
     +           int(float(zyr)/4.0) - xmo
c
c
      return
      end
c
c*******************************************
c
      subroutine monday(julday,year,month,day)
c
c     this subroutine returns the month and day for a given julian
c     day and year
c
      logical leapyr
c
      integer julday,year,month,day,lastda(12,2)
c
      data lastda / 0,31,59,90,120,151,181,212,243,273,304,334,
     1              0,31,60,91,121,152,182,213,244,274,305,335 /
c
      if(leapyr(year)) then
         leap = 2
      else
         leap = 1
      endif
c
      do 10 i=1,12
         if(julday .gt. lastda(i,leap)) month = i
   10 continue
c
      day = julday - lastda(month,leap)
c
      return
      end
c
c*******************************************
c
      logical function leapyr(iyr)
c
c---- this function returns a flag signifying whether or
c     not a year is a leap year
c            false = not a leap year
c            true  = leap year
c
      integer iyr, year
c
      year = iyr
      if(year .lt. 1900) year = year + 1900
      if((mod(year,4) .eq. 0) .and. (mod(year,100) .ne. 0) .or.
     1   (mod(year,400) .eq. 0)) then
          leapyr = .true.
      else
          leapyr = .false.
      endif
c
      return
      end
c
c*******************************************
c
      integer function julian(year,month,day)
c
c--- julian - this function returns the julian day for a given date
c
      integer year,month,day
      integer gdate
c
      julian = gdate(year,month,day) - gdate(year,1,1) + 1
c
c
      return
      end

c                                                                     c
c*********************************************************************c
c                                                                     c
      subroutine mconvert(mdate,mhour,idir,nsplityear)
c
c   mdate: an 8-digit integer specification for a date,
c      given as yymmddhh
c   mhour: an integer specificying the number of hours since
c      00 UTC 1 January 1 AD.
c
c   This routine converts an mdate to an mhour if idir=1, or vice versa
c   if idir=-1.
c
c   If idir=1, how do we know what century mdate refers to?  You
c   provide a year, called "nsplityear", denoted "aabb".  If mdate
c   is denoted "yymmddhh", then if yy >or= bb, the century is
c   assumed to be aa.  Otherwise it is assumed to be the century
c   after aa, or aa+1.
c
c   Leap year definition: every fourth year has a 29th day in February,
c      with the exception of century years not divisible by 400.
c
      dimension ndaypmo(12)
      integer yy,mm,dd,hh,aa,bb
      data ndaypmo /31,28,31,30,31,30,31,31,30,31,30,31/
c
      if (idir.eq.1) then
c
      yy=mdate/1000000
      bb=mod(nsplityear,100)
      aa=nsplityear-bb
      iyear=aa+yy
      if (yy.lt.bb) iyear=iyear+100
      iyearp=iyear-1
      idayp = iyearp*365 + iyearp/4 - iyearp/100 +iyearp/400
      mm=mod(mdate,1000000)/10000
      imonthp=mm-1
      if ((mod(iyear,4).eq.0.and.mod(iyear,100).ne.0).or.
     &    mod(iyear,400).eq.0)
     &   ndaypmo(2)=29
      do 5 i=1,imonthp
         idayp=idayp+ndaypmo(i)
 5    continue
      ndaypmo(2)=28
      dd=mod(mdate,10000)/100
      idayp=idayp+dd-1
      hh=mod(mdate,100)
      mhour=24*idayp+hh
c
      else
c
      nhour=mhour
c
c   Get an estimate of iyear that is guaranteed to be close to but
c   less than the current year
c
      iyear = max(0,nhour-48)*1.14079e-4
      ihour=24*(iyear*365+iyear/4-iyear/100+iyear/400)
 10   iyear=iyear+1
      ihourp=ihour
      ihour = 24*(iyear*365 + iyear/4 - iyear/100 +iyear/400)
      if (ihour.le.nhour) goto 10
      nhour=nhour-ihourp
      if ((mod(iyear,4).eq.0.and.mod(iyear,100).ne.0).or.
     &    mod(iyear,400).eq.0)
     &   ndaypmo(2)=29
      imo=0
      ihour=0
 20   imo=imo+1
      ihourp=ihour
      ihour=ihour+24*ndaypmo(imo)
      if (ihour.le.nhour) goto 20
      nhour=nhour-ihourp
      ndaypmo(2)=28
      iday = nhour/24 + 1
      ihour=mod(nhour,24)
      mdate=mod(iyear,100)*1000000+imo*10000+iday*100+ihour
c
      endif
c
      return
      end
