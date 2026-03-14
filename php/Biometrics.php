<?php

namespace PhpToro\Plugins\Biometrics;

class Biometrics
{
    public static function authenticate(string $reason = 'Authenticate to continue', array $options = []): array
    {
        $args = array_merge($options, ['reason' => $reason]);
        $json = phptoro_native_call('biometrics', 'authenticate', json_encode($args));
        return json_decode($json, true) ?? [];
    }

    public static function isAvailable(): array
    {
        $json = phptoro_native_call('biometrics', 'isAvailable', '{}');
        return json_decode($json, true) ?? [];
    }

    public static function biometryType(): string
    {
        $json = phptoro_native_call('biometrics', 'biometryType', '{}');
        return json_decode($json, true) ?? 'unknown';
    }
}
