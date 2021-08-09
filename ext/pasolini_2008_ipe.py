# -*- coding: utf-8 -*-
# vim: tabstop=4 shiftwidth=4 softtabstop=4
#
# Copyright (C) 2015-2021 GEM Foundation
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
Module exports :
class:`PasoliniEtAl2008`,

"""
import numpy as np

from openquake.hazardlib.gsim.base import GMPE, CoeffsTable
from openquake.hazardlib import const
from openquake.hazardlib.imt import MMI



def _compute_magnitude_term(self, C, mag):
        """
        Returns the magnitude scaling term
        """
        return C["m1"] + (C["m2"] * mag)

def _compute_distance_term(self, C, repi):
        """
        Returns the distance scaling term
        """
        D_1 = np.sqrt(repi**2 + C['d2']**2)
        D_2 = np.log(D_1) - np.log(C['d2'])

        return C["d1"] * (D_1 - C['d2']) + C['d3'] * D_2


class PasoliniEtAl2008(GMPE):
    """
    Implements the Intensity Prediction Equation of Pasolini Albarello Gasperini
    D'Amico Lolli for MCS Intensity in Italy
    Pasolini C., Albarello D., Gasperini P., D'Amico V. and Lolli B. (2008)
    The Attenuation of Seismic Intensity in Italy, Part II: Modeling and
    Validation, BSSA, 98,2 692 - 708
    The coefficient has been reviewed for the seismic hazarda map of Italy in
    ad internal report not published.

    This class implements the version using epicentral distancem, with fixed
    depth, neglecting site amplification

    Model implemented by licia.faenza@ingv.it
    """

    DEFINED_FOR_TECTONIC_REGION_TYPE = const.TRT.ACTIVE_SHALLOW_CRUST

    DEFINED_FOR_INTENSITY_MEASURE_TYPES = {MMI}

    DEFINED_FOR_INTENSITY_MEASURE_COMPONENT = const.IMC.HORIZONTAL

    DEFINED_FOR_STANDARD_DEVIATION_TYPES = {const.StdDev.TOTAL}

    REQUIRES_SITES_PARAMETERS = set()

    REQUIRES_RUPTURE_PARAMETERS = {'mag'}

    REQUIRES_DISTANCES = {'repi'}

    fixedh = None

    def compute(self, ctx, imts, mean, sig, tau, phi):
        """
        See :meth:`superclass method
        <.base.GroundShakingIntensityModel.compute>`
        for spec of input and result values.
        """

        for m, imt in enumerate(imts):
            C = self.COEFFS[imt]
            mean[m] = (_compute_magnitude_term(C, ctx.mag) +
                       _compute_distance_term(C, ctx.repi))
            # the total standard deviation, which is a function of distance
            sig[m] = C["s1"]

    COEFFS = CoeffsTable(table="""
    IMT     m1     m2      d1     d2    d3     s1
    mmi  -2.466 1.842  -0.0085  4.27  -1.049 0.652584
    """)
