# -*- coding: utf-8 -*-
# vim: tabstop=4 shiftwidth=4 softtabstop=4
#
# Copyright (C) 2015-2018 GEM Foundation
#
# OpenQuake is free software: you can redistribute it and/or modify it
# under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# OpenQuake is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with OpenQuake. If not, see <http://www.gnu.org/licenses/>.

"""
Module exports :class:'PasoliniEtAl2008',
"""
import numpy as np

from openquake.hazardlib.gsim.base import IPE, CoeffsTable
from openquake.hazardlib import const
from openquake.hazardlib.imt import MMI


class PasoliniEtAl2008(IPE):
    """
    Implements the Intensity Prediction Equation of Pasolini Albarello Gasperini
    D'Amico Lolli for MCS Intensity in Italy
    Pasolini C., Albarello D., Gasperini P., D'Amico V. and Lolli B. (2008)
    The Attenuation of Seismic Intensity in Italy, Part II: Modeling and
    Validation, BSSA, 98,2 692 - 708
    The coefficient has been reviewed for the seismic hazarda map of Italy in
    ad internal report not published.

    This class implements the version using ipocentral distance, neglecting
    site amplification
    """
    #: The GMPE is derived from induced earthquakes
    DEFINED_FOR_TECTONIC_REGION_TYPE = const.TRT.ACTIVE_SHALLOW_CRUST

    #: Supported intensity measure types are peak ground acceleration
    #: and peak ground velocity
    DEFINED_FOR_INTENSITY_MEASURE_TYPES = set([
        MMI,
    ])

    #: Supported intensity measure component is not considered for IPEs, so
    #: we assume equivalent to 'average horizontal'
    DEFINED_FOR_INTENSITY_MEASURE_COMPONENT = const.IMC.AVERAGE_HORIZONTAL

    #: Supported standard deviation types is total.
    DEFINED_FOR_STANDARD_DEVIATION_TYPES = set([
        const.StdDev.TOTAL
    ])

    #: No required site parameters (in the present version)
    REQUIRES_SITES_PARAMETERS = set()

    #: Required rupture parameters are magnitude (ML is used)
    REQUIRES_RUPTURE_PARAMETERS = set(('mag', ))

    #: Required distance measure is rupture distance
    REQUIRES_DISTANCES = set(('rhypo',))




    def get_mean_and_stddevs(self, sites, rup, dists, imt, stddev_types):
        """
        See :meth:`superclass method
        <.base.GroundShakingIntensityModel.get_mean_and_stddevs>`
        for spec of input and result values.
        """
        C = self.COEFFS[imt]

        mean = (self._compute_magnitude_term(C, rup.mag) +
                self._compute_distance_term(C, dists.rhypo, rup.mag))
        stddevs = self._get_stddevs(C, dists.rhypo, stddev_types)
        return mean, stddevs


    def _compute_magnitude_term(self, C, mag):
        """
        Returns the magnitude scaling term
        """
        return C["m1"] + (C["m2"] * mag)


    def _compute_distance_term(self, C, rhypo, mag):
        """
        Returns the distance scaling term
        """
        D_1 = np.sqrt(rhypo**2 + C['d2']**2)
        D_2 = np.log(D_1)- np.log(C['d2'])

        return C["d1"] * (D_1 - C['d2']) + C['d3'] * D_2


    def _get_stddevs(self, C, distance, stddev_types):
        """
        Returns the total standard deviation
        """
        stddevs = []
        for stddev_type in stddev_types:
            assert stddev_type in self.DEFINED_FOR_STANDARD_DEVIATION_TYPES
            if stddev_type == const.StdDev.TOTAL:
                sigma = C["s1"]
                stddevs.append(sigma)
        return stddevs

    COEFFS = CoeffsTable(sa_damping=5, table="""
    IMT     m1     m2      d1   d2     d3      s1
    mmi  -2.466  1.842  -0.0085  4.27  -1.049  0.652584 
    """)
