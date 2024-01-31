# third party imports
import numpy as np

# stdlib imports
from openquake.hazardlib.imt import PGA, PGV, SA
from shakelib.gmice.gmice import GMICE


class OFM22(GMICE):
    """
    Implements the ground motion intensity conversion equations (GMICE) of
    Oliveti Faenza Michelini (2022).

    References:
        Oliveti Faenza Michelini,(2022). New reversible relationships between
        ground motion parameters and macroseismic intensity for Italy and
        their application in ShakeMap.
        Geophysical Journal International, 231(2),1117–1137,
        https://doi.org/10.1093/gji/ggac245
    """

    # -----------------------------------------------------------------------
    # MMI = C1 + C2 * log10 (Y) + C3 * log10 (Y) * log10(Y)
    #
    # This equation is valid only for intensitied greater than ~ 3,
    # since we calibate the data with this intensity as low values.
    # for intensity values smaller than 3, we used a straight line
    # whose values are indicatively similar to those of FM10.
    # We have adopted this strategy because we are most interested
    # in calibrating large intensity values as accurately as possible
    #
    # MMI = D1 + D2 * log10(Y)
    #
    # The value at which is occurs is in the variable IL
    #
    # Limit the distance residuals to between 0 and 300 km.
    # Limit the magnitude residuals to between M 4.0 and M6.9.
    # These are the default in the other gmice
    #      Limit the distance residuals to between 10 and 300 km.
    #      Limit the magnitude residuals to between M3.0 and M7.3.
    #
    # These are calcualted on the basis of the maximum horizontal component.
    # -----------------------------------------------------------------------
    def __init__(self):
        super().__init__()
        self.min_max = (1.0, 10.0)
        self.name = 'Oliveti Faenza Michelini (2022)'
        self.scale = 'scale_ofm22.ps'
        self._constants = {
                self._pga: {'C1':  3.01, 'C2':  0, 'C3':  0.86, 'D1': 1.637,'D2': 2.415, 'IL': 3.55, 'SMMI': 0.16, 'SPGM': 0.25},
                self._pgv: {'C1':  4.31, 'C2':  1.99, 'C3':  0.58, 'D1': 4.635, 'D2': 2.078, 'IL': 3.23, 'SMMI': 0.15, 'SPGM': 0.31},
                self._sa03: {'C1':  2.77, 'C2':  0, 'C3':  0.68, 'D1': 1.212, 'D2': 2.183, 'IL': 3.55, 'SMMI': 0.14, 'SPGM': 0.28},
                self._sa10: {'C1':  3.00, 'C2':  0.91, 'C3':  0.51, 'D1': 2.832, 'D2': 1.772, 'IL': 3.23, 'SMMI': 0.14, 'SPGM': 0.38},
                self._sa30: {'C1':  4.04, 'C2':  1.63, 'C3':  0.66, 'D1': 4.235, 'D2': 1.955, 'IL': 3.55, 'SMMI': 0.14, 'SPGM': 0.35}
        }

        self.DEFINED_FOR_INTENSITY_MEASURE_TYPES = set([
            PGA,
            PGV,
            SA
        ])

        self.DEFINED_FOR_SA_PERIODS = set([0.3, 1.0, 3.0])

    def getMIfromGM(self, amps, imt, dists=None, mag=None):
        """
        Function to compute macroseismic intensity from ground-motion
        intensity. Supported ground-motion IMTs are PGA, PGV and PSA
        at 0.3, 1.0, and 3.0 sec periods.

        Args:
            amps (ndarray):
                Ground motion amplitude; natural log units; g for PGA and
                PSA, cm/s for PGV.
            imt (OpenQuake IMT):
                Type the input amps (must be one of PGA, PGV, or SA).
                Supported SA periods are 0.3, 1.0, and 3.0 sec.
                `[link] <http://docs.openquake.org/oq-hazardlib/master/imt.html>`
            dists (ndarray):
                Not used.
            mag (float):
                Not used.

        Returns:
            ndarray of Modified Mercalli Intensity and ndarray of
            dMMI / dln(amp) (i.e., the slope of the relationship at the
            point in question).
        """  # noqa
        lfact = np.log10(np.e)
        c = self._getConsts(imt)

        #
        # Convert (for accelerations) from ln(g) to cm/s^2
        # then take the log10
        #
        if imt != self._pgv:
            units = 981.0
        else:
            units = 1.0
        #
        # Math: log10(981 * exp(amps)) = log10(981) + log10(exp(amps))
        # = log10(981) + amps * log10(e)
        # For PGV, just convert ln(amp) to log10(amp) by multiplying
        # by log10(e)
        #
        lamps = np.log10(units) + amps * lfact
        mmi = np.zeros_like(amps)
        dmmi_damp = np.zeros_like(amps)

        #
        # This part is for small intensity < c['IL']
        #
        idx = mmi <= c['IL']
        mmi[idx] = c['D1']+ c['D2'] * lamps[idx]
        dmmi_damp[idx] = c['D2'] * lfact

        # This is for larger values of intensity
        idx = mmi > c['IL']
        mmi[idx] = c['C1'] + c['C2'] * lamps[idx] + c['C3'] * lamps[idx] * lamps[idx]
        dmmi_damp[idx] = c['C2'] * lfact + 2 * c['C3'] * lfact * lamps[idx]
        mmi = np.clip(mmi, 1.0, 10.0)
        mmi[np.isnan(amps)] = np.nan
        return mmi, dmmi_damp


    def getGMfromMI(self, mmi, imt, dists=None, mag=None):
        """
        Function to tcompute ground-motion intensity from macroseismic
        intensity. Supported IMTs are PGA, PGV and PSA for 0.3, 1.0, and
        3.0 sec periods.

        Args:
            mmi (ndarray):
                Macroseismic intensity.
            imt (OpenQuake IMT):
                IMT of the requested ground-motions intensities (must be
                one of PGA, PGV, or SA).
                `[link] <http://docs.openquake.org/oq-hazardlib/master/imt.html>`
            dists (ndarray):
                Not used.
            mag (float):
                Not used.

        Returns:
            Ndarray of ground motion intensity in natural log of g for PGA
            and PSA, and natural log cm/s for PGV; ndarray of dln(amp) / dMMI
            (i.e., the slope of the relationship at the point in question).
        """  # noqa
        lfact = np.log10(np.e)
        c = self._getConsts(imt)
        mmi = mmi.copy()
        # Set nan values to 1
        ix_nan = np.isnan(mmi)
        mmi[ix_nan] = 1.0

        pgm = np.zeros_like(mmi)
        dpgm_dmmi = np.zeros_like(mmi)

        #
        # MMI to PGM
        #

        # This part is for small intensity < c['IL']
        idx = mmi <= c['IL']
        pgm[idx] = np.power(10, (mmi[idx] - c['D1']) / c['D2'])
        dpgm_dmmi[idx] = 1.0 / (c['D2'] * lfact)

        # This is for larger values of intensity
        idx= mmi > c['IL']
        pgm[idx] = np.power(10, ((-c['C2']+np.sqrt(c['C2']*c['C2'] -
                        4 * c['C3'] * (c['C1']-mmi[idx])))/(2*c['C3'])))
        dpgm_dmmi[idx] = 1.0 / (np.sqrt(c['C2']*c['C2'] -
                        4 * c['C3'] * (c['C1']-mmi[idx])) * lfact)

        if imt != self._pgv:
            units = 981.0
        else:
            units = 1.0

        # Return a ln(amp) value. Convert PGA to from cm/s^2 to g
        pgm /= units
        pgm = np.log(pgm)

        # Set nan values back from 1 to nan
        pgm[ix_nan] = np.nan
        dpgm_dmmi[ix_nan] = np.nan

        return pgm, dpgm_dmmi


    def getGM2MIsd(self):
        """
        Return a dictionary of standard deviations for the ground-motion
        to MMI conversion. The keys are the ground motion types.

        Returns:
            Dictionary of GM to MI sigmas (in MMI units).
        """
        return {self._pga: self._constants[self._pga]['SMMI'],
                self._pgv: self._constants[self._pgv]['SMMI'],
                self._sa03: self._constants[self._sa03]['SMMI'],
                self._sa10: self._constants[self._sa10]['SMMI'],
                self._sa30: self._constants[self._sa30]['SMMI']}

    def getMI2GMsd(self):
        """
        Return a dictionary of standard deviations for the MMI
        to ground-motion conversion. The keys are the ground motion
        types.

        Returns:
            Dictionary of MI to GM sigmas (ln(PGM) units).
        """
        #
        # Need to convert log10 to ln units
        #
        lfact = np.log(10.0)
        return {self._pga: lfact * self._constants[self._pga]['SPGM'],
                self._pgv: lfact * self._constants[self._pgv]['SPGM'],
                self._sa03: lfact * self._constants[self._sa03]['SPGM'],
                self._sa10: lfact * self._constants[self._sa10]['SPGM'],
                self._sa30: lfact * self._constants[self._sa30]['SPGM']}

    def _getConsts(self, imt):
        """
        Helper function to get the constants.
        """

        if (imt != self._pga and imt != self._pgv and imt != self._sa03 and
                imt != self._sa10 and imt != self._sa30):
            raise ValueError("Invalid IMT " + str(imt))
        c = self._constants[imt]
        return (c)
