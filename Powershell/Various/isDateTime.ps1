
  function isDateTime($date) 
    { 
        $isDateTime = $date -is [System.Date]
        return $isDateTime 
    } 