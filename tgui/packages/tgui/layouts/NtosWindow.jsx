/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Box, Button } from '../components';
import { Window } from './Window';

export const NtosWindow = (props) => {
  const { title, width = 575, height = 700, theme = 'ntos', children } = props;
  const { act, data } = useBackend();
  const {
    PC_device_theme,
    PC_batteryicon,
    PC_showbatteryicon,
    PC_batterypercent,
    PC_ntneticon,
    PC_AntiVirus,
    PC_apclinkicon,
    PC_stationtime,
    PC_stationdate,
    PC_programheaders = [],
    PC_showexitprogram,
    PC_classic_color,
  } = data;
  return (
    <Window
      title={title}
      width={width}
      height={height}
      theme={PC_device_theme || theme}
      override_bg={PC_classic_color && PC_device_theme === 'thinktronic-classic' ? PC_classic_color : null}>
      <div className="NtosWindow">
        <div className="NtosWindow__header NtosHeader">
          <div className="NtosHeader__left">
            <Box inline bold mr={2}>
              <Button
                width="26px"
                lineHeight="22px"
                textAlign="left"
                tooltip={PC_stationdate}
                color="transparent"
                icon="calendar"
                tooltipPosition="bottom"
              />
              {PC_stationtime}
            </Box>
            <Box inline italic mr={2} opacity={0.33}>
              {PC_device_theme?.startsWith('ntos') && 'NtOS'}
              {PC_device_theme === 'syndicate' && 'Syndix'}
            </Box>
          </div>
          <div className="NtosHeader__right">
            {PC_programheaders.map((header) => (
              <Box key={header.icon} inline mr={1}>
                <img className="NtosHeader__icon" src={resolveAsset(header.icon)} />
              </Box>
            ))}
            {PC_AntiVirus && (
              <Box inline mr={1}>
                <img className="NtosHeader__icon" src={resolveAsset(PC_AntiVirus)} alt="Antivirus status" />
              </Box>
            )}
            <Box inline>{PC_ntneticon && <img className="NtosHeader__icon" src={resolveAsset(PC_ntneticon)} />}</Box>
            {!!PC_showbatteryicon && PC_batteryicon && (
              <Box inline mr={1}>
                {PC_batteryicon && <img className="NtosHeader__icon" src={resolveAsset(PC_batteryicon)} />}
                {PC_batterypercent && PC_batterypercent}
              </Box>
            )}
            {PC_apclinkicon && (
              <Box inline mr={1}>
                <img className="NtosHeader__icon" src={resolveAsset(PC_apclinkicon)} />
              </Box>
            )}
            {!!PC_showexitprogram && (
              <Button
                width="26px"
                lineHeight="22px"
                textAlign="center"
                color="transparent"
                icon="window-minimize-o"
                tooltip="Minimize"
                tooltipPosition="bottom"
                onClick={() => act('PC_minimize')}
              />
            )}
            {!!PC_showexitprogram && (
              <Button
                mr="-3px"
                width="26px"
                lineHeight="22px"
                textAlign="center"
                color="transparent"
                icon="window-close-o"
                tooltip="Close"
                tooltipPosition="bottom-start"
                onClick={() => act('PC_exit')}
              />
            )}
            {!PC_showexitprogram && (
              <Button
                mr="-3px"
                width="26px"
                lineHeight="22px"
                textAlign="center"
                color="transparent"
                icon="power-off"
                tooltip="Power off"
                tooltipPosition="bottom-start"
                onClick={() => act('PC_shutdown')}
              />
            )}
          </div>
        </div>
        {children}
      </div>
    </Window>
  );
};

const NtosWindowContent = (props) => {
  return (
    <div className="NtosWindow__content">
      <Window.Content {...props} />
    </div>
  );
};

NtosWindow.Content = NtosWindowContent;
