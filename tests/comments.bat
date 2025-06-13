
   Not a comment! (code)

   :Not a comment! (label)

   ::Body Comment   (<<start>>=::)

   :: Body Comment   (<<start>>=::)

   ::: Body Comment    (<<start>>=:::)

   :::: Body Comment    (<<start>>=::::)

   rem Body Comment    (<<start>>=rem )

   :.Section1              Begin Section1 (depth 1)
   ::    Test:    <<section>>=.Section1
   ::    Result:  <<section>>=<section>
   ::
   :: .Section1.Sub1         Append <<subtitle>>=Sub1 (depth 2)
   ::    Test:    <<section>>=.Section1.Sub1
   ::    Result:  <<section>>=<section>
   ::
   :: .Section1.Sub1.Sub2    Append <<subtitle>> (depth 3)
   ::    Test:    <<section>>=.Section1.Sub1.Sub2
   ::    Result:  <<section>>=<section>
   ::
/ SECTION BREAK
/  :.Section2.Sub1         Begin Section2.Sub1
/  ::    Test:    <<section>>=.Section2.Sub1
/  ::    Result:  <<section>>=<section>
/  ::
/  :: .Section2.Sub1_new         Partial replacement
/  ::    Test:    <<section>>=.Section2.Sub1_new
/  ::    Result:  <<section>>=<section>
/  ::
/  :: .Section3              Full replacement
/  ::    Test:    <<section>>=.Section3
/  ::    Result:  <<section>>=<section>
/  ::
/ SECTION BREAK
/  :: .Section4.Sub1.Sub2    Begin Section4.Sub1.Sub2
/  ::    Test:    <<section>>=.Section4.Sub1.Sub2
/  ::    Result:  <<section>>=<section>
/  :: ...    Full Continuation
/  ::    Test:    <<section>>=.Section4.Sub1.Sub2
/  ::    Result:  <<section>>=<section>
/  ::
/  :: .    Partial Continuation
/  ::    Test:    <<section>>=.Section4
/  ::    Result:  <<section>>=<section>
/  ::
  SECTION BREAK
   :: .    Begin section <<null>>
   ::    Test:    <<section>>=<<null>>
   ::    Result:  <<section>>=<section>
   ::
   :: ..Sub1    Append <<subtitle>>=Sub1 (depth 2)
   ::    Test:    <<section>>=.<<null>>.Sub1
   ::    Result:  <<section>>=<section>
   ::
   :: ...    Append <<subtitle>>=<<null>> (depth 3)
   ::    Test:    <<section>>=.<<null>>.Sub1.<<null>>
   ::    Result:  <<section>>=<section>
   ::
   :: ....   Append <<subtitle>>=<<null>> (depth 4)
   ::    Test:    <<section>>=.<<null>>.Sub1.<<null>>
   ::    Result:  <<section>>=<section>
   ::
   :: ..    Partial Continuation
   ::    Test:    <<section>>=.<<null>>.Sub1
   ::    Result:  <<section>>=<section>
   ::
