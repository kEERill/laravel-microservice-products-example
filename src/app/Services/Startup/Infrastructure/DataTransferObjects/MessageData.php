<?php

namespace App\Services\Startup\Infrastructure\DataTransferObjects;

use Spatie\LaravelData\Data;

final class MessageData extends Data
{
    public function __construct(
        public string $message
    ) {}
}
