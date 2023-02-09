<?php

namespace App\Services\Startup\Domain\Subservices;

use App\Services\Startup\Infrastructure\Contracts\GetStartupMessageInterface;
use App\Services\Startup\Infrastructure\DataTransferObjects\MessageData;
use Micromus\MicroserviceStructure\Attributes\RegisterAction;

final class StartupSubservice
    implements GetStartupMessageInterface
{
    #[RegisterAction(GetStartupMessageInterface::class)]
    public function getStartupMessage(): MessageData
    {
        return new MessageData(message: 'Hello world');
    }
}
