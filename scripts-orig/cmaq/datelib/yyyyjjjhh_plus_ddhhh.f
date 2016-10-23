      program  yyyjjjhh_plus_ddhh
c****************************************
c this program reads a command line 
c   YYYYJJJHH julian date and adds
c   a string of the form ddhh
c
c***************************************
      character*10 card  
      integer julian,ady,ahr,iout
      logical leapyr,leap

      call getarg(1,card)
      read(card,'(i4,i3,i2)')iyr,jdy,ihr
      call getarg(2,card)
      read(card,'(i2,i3)')ady,ahr

      ihr = ihr + ahr
      do while (ihr .gt. 23)
        ihr = ihr - 24
        jdy = jdy + 1
      end do

      do while (ihr .lt. 0)
        ihr = ihr + 24
        jdy = jdy - 1
      end do

      jdy = jdy + ady

      leap = leapyr(iyr)
      if (leap) then
        ndyyr = 366
      else
        ndyyr = 365
      end if

      do while (jdy .gt. ndyyr)
        jdy = jdy - ndyyr
        iyr = iyr + 1
      end do

      write(*,'(i4,i3.3,i2.2)')
     1       iyr,jdy,ihr
      
c     jdate = 100000*iyr+
c    1        100*julian(iyr,imo,idy)+
c    2        ihr
c     write(*,'(i9)')jdate
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
