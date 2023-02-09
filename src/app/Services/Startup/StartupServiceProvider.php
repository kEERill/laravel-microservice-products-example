<?php

namespace App\Services\Startup;

use Micromus\MicroserviceStructure\Services\AbstractServiceProvider;
use Micromus\MicroserviceStructure\Services\ServiceConfigurator;

final class StartupServiceProvider extends AbstractServiceProvider
{
    /**
     * @param ServiceConfigurator $serviceConfigurator
     * @return void
     */
    protected function configureService(ServiceConfigurator $serviceConfigurator): void
    {
        $serviceConfigurator->usingRoutes();
    }
}
