﻿using System;
using System.Collections.Generic;

#nullable disable

namespace DiCho.DataService.Models
{
    public partial class CampaignArea
    {
        public int Id { get; set; }
        public int? CampaignId { get; set; }
        public int? DeliveryZoneId { get; set; }

        public virtual Campaign Campaign { get; set; }
        public virtual DeliveryZone DeliveryZone { get; set; }
    }
}
